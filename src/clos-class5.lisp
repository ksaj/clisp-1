;;;; Common Lisp Object System for CLISP: Classes
;;;; Bruno Haible 21.8.1993 - 2004
;;;; Sam Steingold 1998 - 2004
;;;; German comments translated into English: Stefan Kain 2002-04-08

(in-package "CLOS")


;;; 28.1.9. Object creation and initialization

;; Cruel hack (CLtL2 28.1.9.2., ANSI CL 7.1.2.):
;; - MAKE-INSTANCE must be informed about the methods of ALLOCATE-INSTANCE,
;;   INITIALIZE-INSTANCE and SHARED-INITIALIZE.
;; - INITIALIZE-INSTANCE must be informed about the methods of
;;   INITIALIZE-INSTANCE and SHARED-INITIALIZE.
;; - REINITIALIZE-INSTANCE must be informed about the methods of
;;   REINITIALIZE-INSTANCE and SHARED-INITIALIZE.

(defparameter *make-instance-table* (make-hash-table :test #'eq))
  ;; Hash table, mapping a class to a simple-vector containing
  ;; - a list of valid keyword arguments,
  ;; - the effective method of allocate-instance,
  ;; - the effective method of initialize-instance,
  ;; - the effective method of shared-initialize.

(defparameter *reinitialize-instance-table* (make-hash-table :test #'eq))
  ;; Hash table, mapping a class to a cons containing
  ;; - a list of valid keyword arguments,
  ;; - the effective method of shared-initialize.

(defun note-i-change (specializer table)
  (maphash #'(lambda (class value) (declare (ignore value))
               (when (subclassp class specializer)
                 (remhash class table)))
           table))
(defun note-i-meta-change (meta-specializer table)
  (maphash #'(lambda (class value) (declare (ignore value))
               (when (subclassp (class-of class) meta-specializer) ; <==> (typep class meta-specializer)
                 (remhash class table)))
           table))

(defun note-ai-change (method)
  (let ((specializer (first (std-method-parameter-specializers method))))
    (if (consp specializer)
      ;; EQL-method for ALLOCATE-INSTANCE:
      ;; object must be a class, else worthless
      (let ((specialized-object (second specializer)))
        (when (class-p specialized-object)
          ;; remove the entries from *make-instance-table* for which the
          ;; implied method might be applicable:
          (note-i-change specialized-object *make-instance-table*)))
      ;; remove the entries from *make-instance-table* for which the
      ;; implied method might be applicable:
      (note-i-meta-change specializer *make-instance-table*))))

(defun note-ii-change (method)
  (let ((specializer (first (std-method-parameter-specializers method))))
    ;; EQL-methods for INITIALIZE-INSTANCE are worthless in any case
    (unless (consp specializer)
      ;; remove the entries from *make-instance-table* for which the
      ;; implied method might be applicable:
      (note-i-change specializer *make-instance-table*))))

(defun note-ri-change (method)
  (let ((specializer (first (std-method-parameter-specializers method))))
    ;; EQL-methods for REINITIALIZE-INSTANCE are essentially worthless
    (unless (consp specializer)
      ;; remove the entries from *reinitialize-instance-table* for which the
      ;; implied method might be applicable:
      (note-i-change specializer *reinitialize-instance-table*))))

(defun note-si-change (method)
  (let* ((specializers (std-method-parameter-specializers method))
         (specializer1 (first specializers))
         (specializer2 (second specializers)))
    ;; EQL-methods for SHARED-INITIALIZE are essentially worthless
    (unless (consp specializer1)
      ;; As second argument, INITIALIZE-INSTANCE passes always T .
      (when (typep 'T specializer2)
        ;; remove the entries from *make-instance-table* for which the
        ;; implied method might be applicable:
        (note-i-change specializer1 *make-instance-table*))
      ;; As second argument, REINITIALIZE-INSTANCE passes always NIL .
      (when (typep 'NIL specializer2)
        ;; remove the entries from *reinitialize-instance-table* for which the
        ;; implied method might be applicable:
        (note-i-change specializer1 *reinitialize-instance-table*)))))

;;; collect all keywords from a list of applicable methods
(defun valid-initarg-keywords (class methods)
  (let ((signatures (mapcar #'std-method-signature methods)))
    ;; "A method that has &rest but not &key does not affect the set of
    ;;  acceptable keyword srguments."
    (setq signatures (delete-if-not #'sig-keys-p signatures))
    ;; "The presence of &allow-other-keys in the lambda list of an applicable
    ;;  method disables validity checking of initialization arguments."
    ;; (ANSI CL section 7.1.2)
    (if (some #'sig-allow-p signatures)
      't
      ;; "The keyword name of each keyword parameter specified in the method's
      ;;  lambda-list becomes an initialization argument for all classes for
      ;;  which the method is applicable."
      (remove-duplicates
       (append (class-valid-initargs class) (mapcap #'sig-keywords signatures))
       :from-end t))))

;; NB: On calculation of an effective method, the residual
;; arguments do not count.
;; At the first call of INITIALIZE-INSTANCE or MAKE-INSTANCE of each class
;; we memorize the needed information in *make-instance-table*.

;; For MAKE-INSTANCE the following is necessary as keys:
;; - the initargs that are used for the initialization of slots,
;; - the keywords of methods from SHARED-INITIALIZE,
;; - the keywords of methods from INITIALIZE-INSTANCE,
;; - the keywords of methods from ALLOCATE-INSTANCE.
(defun valid-make-instance-keywords (class)
  (valid-initarg-keywords
    class
    (append ; list of all applicable methods from SHARED-INITIALIZE
     (remove-if-not
      #'(lambda (method)
          (let* ((specializers (std-method-parameter-specializers method))
                 (specializer1 (first specializers))
                 (specializer2 (second specializers)))
            (and (atom specializer1) (subclassp class specializer1)
                 (typep 'T specializer2))))
      (gf-methods |#'shared-initialize|))
     ;; list of all applicable methods from INITIALIZE-INSTANCE
     (remove-if-not
      #'(lambda (method)
          (let ((specializer
                 (first (std-method-parameter-specializers method))))
            (and (atom specializer) (subclassp class specializer))))
      (gf-methods |#'initialize-instance|))
     ;; list of all applicable methods from ALLOCATE-INSTANCE
     (remove-if-not
      #'(lambda (method)
          (let ((specializer
                 (first (std-method-parameter-specializers method))))
            (if (consp specializer)
              (eql class (second specializer))
              (subclassp (class-of class) specializer)))) ; <==> (typep class specializer)
      (gf-methods |#'allocate-instance|)))))
(defun make-instance-table-entry1 (class)
  (values (valid-make-instance-keywords class)
          (compute-effective-method |#'allocate-instance| class)))
(defun make-instance-table-entry2 (instance)
  (values (compute-effective-method |#'initialize-instance| instance)
          (compute-effective-method |#'shared-initialize| instance 'T)))

#|| ;; Now in record.d.
 (defun check-initialization-argument-list (initargs caller)
   (do ((l initargs (cddr l)))
       ((endp l))
     (unless (symbolp (car l))
       (error "~S: invalid initialization argument ~S"
              caller (car l)))
     (when (endp (cdr l))
       (error "~S: keyword arguments in ~S should occur pairwise"
              caller initargs))))
||#

;; 28.1.9.5., 28.1.9.4.
(defgeneric shared-initialize
    (instance slot-names &rest initargs &key &allow-other-keys))
(setq |#'shared-initialize| #'shared-initialize)
#||
 (defmethod shared-initialize ((instance standard-object) slot-names
                               &rest initargs)
  (check-initialization-argument-list initargs 'shared-initialize)
  (dolist (slot (class-slots (class-of instance)))
    (let ((slotname (slotdef-name slot)))
      (multiple-value-bind (init-key init-value foundp)
          (get-properties initargs (slotdef-initargs slot))
        (declare (ignore init-key))
        (if foundp
          (setf (slot-value instance slotname) init-value)
          (unless (slot-boundp instance slotname)
            (let ((init (slotdef-initer slot)))
              (when init
                (when (or (eq slot-names 'T) (memq slotname slot-names))
                  (setf (slot-value instance slotname)
                        (if (car init) (funcall (car init))
                            (cdr init)))))))))))
  instance)
||#
;; the main work is done by a SUBR:
(do-defmethod 'shared-initialize
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%shared-initialize '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'standard-object) (find-class 't))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 2 :rest-p t)))
(do-defmethod 'shared-initialize
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%shared-initialize '(T)))
    :wants-next-method-p nil
    :parameter-specializers
      (list (find-class 'structure-object) (find-class 't))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 2 :rest-p t)))

;; 28.1.12.
(defgeneric reinitialize-instance
    (instance &rest initargs &key &allow-other-keys))
(setq |#'reinitialize-instance| #'reinitialize-instance)
#||
 (defmethod reinitialize-instance ((instance standard-object) &rest initargs)
  (check-initialization-argument-list initargs 'reinitialize-instance)
  (apply #'shared-initialize instance 'NIL initargs))
||#
#|| ; optimized:
 (defmethod reinitialize-instance ((instance standard-object) &rest initargs)
  (check-initialization-argument-list initargs 'reinitialize-instance)
  (let ((h (gethash (class-of instance) *reinitialize-instance-table*)))
    (if h
      (progn
        ;; 28.1.9.2. validity of initialization arguments
        (let ((valid-keywords (car h)))
          (unless (eq valid-keyword 't)
            (sys::keyword-test initargs valid-keywords)))
        (if (not (eq (cdr h) #'clos::%shared-initialize))
          ;; apply effective method from shared-initialize:
          (apply (cdr h) instance 'NIL initargs)
          ;; clos::%shared-initialize with slot-names=NIL can be simplified:
          (progn
            (dolist (slot (class-slots (class-of instance)))
              (let ((slotname (slotdef-name slot)))
                (multiple-value-bind (init-key init-value foundp)
                    (get-properties initargs (slotdef-initargs slot))
                  (declare (ignore init-key))
                  (if foundp
                    (setf (slot-value instance slotname) init-value)))))
            instance)))
      (apply #'initial-reinitialize-instance instance initargs))))
||#
;; the main work is done by a SUBR:
(do-defmethod 'reinitialize-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%reinitialize-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'standard-object))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(do-defmethod 'reinitialize-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%reinitialize-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'structure-object))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
;; At the first call of REINITIALIZE-INSTANCE of each class
;; we memorize the needed information in *reinitialize-instance-table*.
(defun initial-reinitialize-instance (instance &rest initargs)
  (let* ((class (class-of instance))
         (valid-keywords
          (valid-initarg-keywords
           class
           (append
            ;; list of all applicable methods from SHARED-INITIALIZE
            (remove-if-not
             #'(lambda (method)
                 (let* ((specializers (std-method-parameter-specializers
                                       method))
                        (specializer1 (first specializers))
                        (specializer2 (second specializers)))
                   (and (atom specializer1) (subclassp class specializer1)
                        (typep 'NIL specializer2))))
             (gf-methods |#'shared-initialize|))
            ;; list of all applicable methods from REINITIALIZE-INSTANCE
            (remove-if-not
             #'(lambda (method)
                 (let ((specializer
                        (first (std-method-parameter-specializers method))))
                   (and (atom specializer) (subclassp class specializer))))
             (gf-methods |#'reinitialize-instance|))))))
    ;; 28.1.9.2. validity of initialization arguments
    (unless (eq valid-keywords 't)
      (sys::keyword-test initargs valid-keywords))
    (let ((si-ef (compute-effective-method
                  |#'shared-initialize| instance 'NIL)))
      (setf (gethash class *reinitialize-instance-table*)
            (cons valid-keywords si-ef))
      (apply si-ef instance 'NIL initargs))))

;; 28.1.9.6.
(defgeneric initialize-instance (instance &rest initargs
                                 &key &allow-other-keys))
(setq |#'initialize-instance| #'initialize-instance)
#||
 (defmethod initialize-instance ((instance standard-object) &rest initargs)
  (check-initialization-argument-list initargs 'initialize-instance)
  (apply #'shared-initialize instance 'T initargs))
||#
#|| ; optimized:
 (defmethod initialize-instance ((instance standard-object) &rest initargs)
  (check-initialization-argument-list initargs 'initialize-instance)
  (let ((h (gethash class *make-instance-table*)))
    (if h
      (if (not (eq (svref h 3) #'clos::%shared-initialize))
        ;; apply effective method from shared-initialize:
        (apply (svref h 3) instance 'T initargs)
        ;; clos::%shared-initialize with slot-names=T can be simplified:
        (progn
          (dolist (slot (class-slots (class-of instance)))
            (let ((slotname (slotdef-name slot)))
              (multiple-value-bind (init-key init-value foundp)
                  (get-properties initargs (slotdef-initargs slot))
                (declare (ignore init-key))
                (if foundp
                  (setf (slot-value instance slotname) init-value)
                  (unless (slot-boundp instance slotname)
                    (let ((init (slotdef-initer slot)))
                      (when init
                        (setf (slot-value instance slotname)
                              (if (car init) (funcall (car init))
                                  (cdr init))))))))))
          instance))
      (apply #'initial-initialize-instance instance initargs))))
||#
;; the main work is done by a SUBR:
(do-defmethod 'initialize-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%initialize-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'standard-object))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(do-defmethod 'initialize-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%initialize-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'structure-object))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(defun initial-initialize-instance (instance &rest initargs)
  (let ((class (class-of instance)))
    (multiple-value-bind (valid-keywords ai-ef)
        (make-instance-table-entry1 class)
      (multiple-value-bind (ii-ef si-ef) (make-instance-table-entry2 instance)
        (setf (gethash class *make-instance-table*)
              (vector valid-keywords ai-ef ii-ef si-ef))
        ;; apply effective method from SHARED-INITIALIZE:
        (apply si-ef instance 'T initargs)))))

;; User-defined methods on allocate-instance are now supported.
(defgeneric allocate-instance
    (instance &rest initargs &key &allow-other-keys))
(setq |#'allocate-instance| #'allocate-instance)
#||
 (defgeneric allocate-instance (class)
  (:method ((class standard-class))
    (unless (class-precedence-list class) (class-finalize class t))
    (allocate-std-instance class (class-instance-size class)))
  (:method ((class structure-class))
    (sys::%make-structure (class-names class) (class-instance-size class)
                          :initial-element unbound)))
||#
#||
 (defun %allocate-instance (class &rest initargs)
  (check-initialization-argument-list initargs 'allocate-instance)
  ;; Quick and dirty dispatch among <standard-class> and <structure-class>.
  ;; (class-shared-slots class) is a simple-vector, (class-names class) a cons.
  (if (atom (class-shared-slots class))
    (progn (unless (class-precedence-list class) (class-finalize class t))
      (allocate-std-instance class (class-instance-size class)))
    (sys::%make-structure (class-names class) (class-instance-size class)
                          :initial-element unbound)))
||#
; the main work is done by a SUBR:
(do-defmethod 'allocate-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%allocate-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'standard-class))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(do-defmethod 'allocate-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%allocate-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'structure-class))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))

;; 28.1.9.7.
(defgeneric make-instance (class &rest initargs &key &allow-other-keys)
  (:method ((class symbol) &rest initargs)
    (apply #'make-instance (find-class class) initargs)))
#||
 (defmethod make-instance ((class standard-class) &rest initargs)
  (check-initialization-argument-list initargs 'make-instance)
  ;; 28.1.9.3., 28.1.9.4. take note of default-initargs:
  (dolist (default-initarg (class-default-initargs class))
    (let ((nothing default-initarg))
      (when (eq (getf initargs (car default-initarg) nothing) nothing)
        (setq initargs
              (append initargs
                (list (car default-initarg)
                      (let ((init (cdr default-initarg)))
                        (if (car init) (funcall (car init)) (cdr init)))))))))
  #||
  ;; 28.1.9.2. validity of initialization arguments
  (sys::keyword-test initargs
      (union (class-valid-initargs class)
             (applicable-keywords #'initialize-instance class))) ; ??
  (let ((instance (apply #'allocate-instance class initargs)))
    (apply #'initialize-instance instance initargs))
  ||#
  (let ((h (gethash class *make-instance-table*)))
    (if h
      (progn
        ;; 28.1.9.2. validity of initialization arguments
        (let ((valid-keywords (svref h 0)))
          (unless (eq valid-keywords 't)
            (sys::keyword-test initargs valid-keywords)))
        (let ((instance (apply #'allocate-instance class initargs)))
          (if (not (eq (svref h 2) #'clos::%initialize-instance))
            ;; apply effective method from initialize-instance:
            (apply (svref h 2) instance initargs)
            ;; clos::%initialize-instance can be simplified (one does not need
            ;; to look into *make-instance-table* once again):
            (if (not (eq (svref h 3) #'clos::%shared-initialize))
              ;; apply effective method from shared-initialize:
              (apply (svref h 3) instance 'T initargs)
              ...
            ))))
      (apply #'initial-make-instance class initargs))))
||#
;; the main work is done by a SUBR:
(do-defmethod 'make-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%make-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'standard-class))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(do-defmethod 'make-instance
  (make-standard-method
    :initfunction #'(lambda (gf) (declare (ignore gf))
                            (cons #'clos::%make-instance '(T)))
    :wants-next-method-p nil
    :parameter-specializers (list (find-class 'structure-class))
    :qualifiers '()
    :signature #s(compiler::signature :req-num 1 :rest-p t)))
(defun initial-make-instance (class &rest initargs)
  (multiple-value-bind (valid-keywords ai-ef)
      (make-instance-table-entry1 class)
    ;; http://www.lisp.org/HyperSpec/Body/sec_7-1-2.html
    ;; 7.1.2 Declaring the Validity of Initialization Arguments
    (unless (eq valid-keywords 't)
      (sys::keyword-test initargs valid-keywords))
    ;; call the effective method of ALLOCATE-INSTANCE:
    (let ((instance (apply ai-ef class initargs)))
      (unless (eq (class-of instance) class)
        (error-of-type 'error
          (TEXT "~S method for ~S returned ~S")
          'allocate-instance class instance))
      (multiple-value-bind (ii-ef si-ef) (make-instance-table-entry2 instance)
        (setf (gethash class *make-instance-table*)
              (vector valid-keywords ai-ef ii-ef si-ef))
        ;; call the effective method of INITIALIZE-INSTANCE:
        (apply ii-ef instance initargs))
      ;; return the instance
      instance)))

;; Users want to be able to create instances of subclasses of <standard-class>
;; and <structure-class>. So, when creating a class, we now go through
;; MAKE-INSTANCE and INITIALIZE-INSTANCE.
(setf (fdefinition 'make-instance-standard-class) #'make-instance)
(setf (fdefinition 'make-instance-structure-class) #'make-instance)
(defmethod initialize-instance ((new-class-object standard-class) &rest args
                                &key name (metaclass <standard-class>)
                                documentation direct-superclasses direct-slots
                                direct-default-initargs)
  (declare (ignore documentation direct-superclasses direct-slots
                   direct-default-initargs))
  (setf (class-classname new-class-object) name)
  (setf (class-metaclass new-class-object) metaclass) ; = (class-of new-class-object)
  (apply #'initialize-instance-standard-class new-class-object args)
  (call-next-method)
  new-class-object)
(defmethod initialize-instance ((new-class-object structure-class) &rest args
                                &key name (metaclass <structure-class>)
                                documentation direct-superclasses direct-slots
                                direct-default-initargs
                                names slots size)
  (declare (ignore documentation direct-superclasses direct-slots
                   direct-default-initargs names slots size))
  (setf (class-classname new-class-object) name)
  (setf (class-metaclass new-class-object) metaclass) ; = (class-of new-class-object)
  (apply #'initialize-instance-structure-class new-class-object args)
  (call-next-method)
  new-class-object)

;;; change-class
(defgeneric change-class (instance new-class &key &allow-other-keys)
  (:method ((instance standard-object) (new-class standard-class)
            &rest initargs)
    (let* ((old-slots (class-slots (class-of instance)))
           (new-slots (class-slots new-class))
           (previous (%change-class instance new-class t)))
      ;; previous = a copy of instance
      ;; instance: class is changed, slots unbound
      ;; copy identically named slots
      (dolist (slot old-slots)
        (let ((name (slotdef-name slot)))
          (when (slot-boundp previous name)
            (let ((new-slot (find name new-slots :test #'eq
                                  :key #'slotdef-name)))
              (when new-slot
                (setf (slot-value instance name)
                      (slot-value previous name)))))))
      (apply #'update-instance-for-different-class
             previous instance initargs)))
  (:method ((instance t) (new-class symbol) &rest initargs)
    (apply #'change-class instance (find-class new-class) initargs)))

(defgeneric update-instance-for-different-class
    (previous current &key &allow-other-keys)
  (:method ((previous standard-object) (current standard-object)
            &rest initargs)
    (apply #'shared-initialize current
           (slot-difference (class-of current) (class-of previous))
           initargs)))

(defgeneric make-instances-obsolete (class)
  (:method ((class standard-class))
    (let ((name (class-name class)))
      (warn (TEXT "~S: Class ~S (or one of its ancestors) is being redefined, instances are obsolete")
            'defclass name)
      (mapc #'make-instances-obsolete (class-direct-subclasses class)))
    class)
  (:method ((class symbol)) (make-instances-obsolete (find-class class))))

(defgeneric update-instance-for-redefined-class
    (instance added-slots discarded-slots property-list &rest initargs
     &key &allow-other-keys)
  (:method ((instance standard-object) added-slots discarded-slots
            property-list &rest initargs)
    (declare (ignore discarded-slots property-list))
    (apply #'shared-initialize instance added-slots initargs)))

;;; classs prototype (MOP)

(defgeneric class-prototype (class)
  (:method ((class standard-class))
    (or (class-proto class)
        (setf (class-proto class) (clos::%allocate-instance class))))
  (:method ((name symbol)) (class-prototype (find-class name))))

;;; class finalization (MOP)

(defgeneric class-finalized-p (class)
  (:method ((class standard-class)) (not (null (class-precedence-list class))))
  (:method ((name symbol)) (class-finalized-p (find-class name))))

(defgeneric finalize-inheritance (class)
  (:method ((class standard-class)) (class-finalize class t))
  (:method ((name symbol)) (finalize-inheritance (find-class name))))

;;; Utility functions

;; Returns the slot names of an instance of a slotted-class
;; (i.e. of a structure-object or standard-object).
(defun slot-names (object)
  (mapcar #'slotdef-name (class-slots (class-of object))))
