# Liste aller Pseudofunktionen
# Bruno Haible 30.4.1995

# Der Macro PSEUDOFUN deklariert eine Pseudofunktion.
# PSEUDOFUN(fun)
# > fun: C-Funktion

# Expander f�r die Deklaration der Tabelle:
  #define PSEUDOFUN_A(fun)  Pseudofun pseudo_##fun;

# Expander f�r die Initialisierung der Tabelle:
  #define PSEUDOFUN_B(fun)  (Pseudofun)(&fun),

# Welcher Expander benutzt wird, muss vom Hauptfile aus eingestellt werden.

PSEUDOFUN(rd_by_error) PSEUDOFUN(rd_by_array_error) PSEUDOFUN(rd_by_array_dummy)
PSEUDOFUN(wr_by_error) PSEUDOFUN(wr_by_array_error) PSEUDOFUN(wr_by_array_dummy)
PSEUDOFUN(rd_ch_error) PSEUDOFUN(pk_ch_dummy) PSEUDOFUN(rd_ch_array_error) PSEUDOFUN(rd_ch_array_dummy)
PSEUDOFUN(wr_ch_error) PSEUDOFUN(wr_ch_array_error) PSEUDOFUN(wr_ch_array_dummy)
PSEUDOFUN(wr_ss_dummy) PSEUDOFUN(wr_ss_dummy_nogc)

PSEUDOFUN(rd_by_synonym) PSEUDOFUN(rd_by_array_synonym) PSEUDOFUN(wr_by_synonym) PSEUDOFUN(wr_by_array_synonym) PSEUDOFUN(rd_ch_synonym) PSEUDOFUN(pk_ch_synonym) PSEUDOFUN(rd_ch_array_synonym) PSEUDOFUN(wr_ch_synonym) PSEUDOFUN(wr_ch_array_synonym) PSEUDOFUN(wr_ss_synonym)
PSEUDOFUN(wr_by_broad) PSEUDOFUN(wr_by_array_broad0) PSEUDOFUN(wr_by_array_broad1) PSEUDOFUN(wr_ch_broad) PSEUDOFUN(wr_ch_array_broad0) PSEUDOFUN(wr_ch_array_broad1) PSEUDOFUN(wr_ss_broad)
PSEUDOFUN(rd_by_concat) PSEUDOFUN(rd_by_array_concat) PSEUDOFUN(rd_ch_concat) PSEUDOFUN(pk_ch_concat) PSEUDOFUN(rd_ch_array_concat)
PSEUDOFUN(wr_by_twoway) PSEUDOFUN(wr_by_array_twoway) PSEUDOFUN(wr_ch_twoway) PSEUDOFUN(wr_ch_array_twoway) PSEUDOFUN(wr_ss_twoway)
PSEUDOFUN(rd_by_twoway) PSEUDOFUN(rd_by_array_twoway) PSEUDOFUN(rd_ch_twoway) PSEUDOFUN(pk_ch_twoway) PSEUDOFUN(rd_ch_array_twoway)
PSEUDOFUN(rd_by_echo) PSEUDOFUN(rd_ch_echo)
PSEUDOFUN(rd_ch_str_in) PSEUDOFUN(rd_ch_array_str_in)
PSEUDOFUN(wr_ch_str_out) PSEUDOFUN(wr_ss_str_out)
PSEUDOFUN(wr_ch_str_push)
PSEUDOFUN(wr_ch_pphelp) PSEUDOFUN(wr_ss_pphelp)
PSEUDOFUN(rd_ch_buff_in)
PSEUDOFUN(wr_ch_buff_out)
#ifdef GENERIC_STREAMS
PSEUDOFUN(rd_ch_generic) PSEUDOFUN(pk_ch_generic) PSEUDOFUN(wr_ch_generic) PSEUDOFUN(wr_ss_generic) PSEUDOFUN(rd_by_generic) PSEUDOFUN(wr_by_generic)
#endif

PSEUDOFUN(rd_by_iau_unbuffered) PSEUDOFUN(rd_by_ias_unbuffered) PSEUDOFUN(rd_by_iau8_unbuffered) PSEUDOFUN(rd_by_array_iau8_unbuffered)
PSEUDOFUN(wr_by_iau_unbuffered) PSEUDOFUN(wr_by_ias_unbuffered) PSEUDOFUN(wr_by_iau8_unbuffered) PSEUDOFUN(wr_by_array_iau8_unbuffered)
PSEUDOFUN(rd_ch_unbuffered) PSEUDOFUN(rd_ch_array_unbuffered)
PSEUDOFUN(wr_ch_unbuffered_unix) PSEUDOFUN(wr_ch_array_unbuffered_unix) PSEUDOFUN(wr_ss_unbuffered_unix)
PSEUDOFUN(wr_ch_unbuffered_mac) PSEUDOFUN(wr_ch_array_unbuffered_mac) PSEUDOFUN(wr_ss_unbuffered_mac)
PSEUDOFUN(wr_ch_unbuffered_dos) PSEUDOFUN(wr_ch_array_unbuffered_dos) PSEUDOFUN(wr_ss_unbuffered_dos)
PSEUDOFUN(rd_ch_buffered) PSEUDOFUN(rd_ch_array_buffered)
PSEUDOFUN(wr_ch_buffered_unix) PSEUDOFUN(wr_ch_array_buffered_unix) PSEUDOFUN(wr_ss_buffered_unix)
PSEUDOFUN(wr_ch_buffered_mac) PSEUDOFUN(wr_ch_array_buffered_mac) PSEUDOFUN(wr_ss_buffered_mac)
PSEUDOFUN(wr_ch_buffered_dos) PSEUDOFUN(wr_ch_array_buffered_dos) PSEUDOFUN(wr_ss_buffered_dos)
PSEUDOFUN(rd_by_iau_buffered) PSEUDOFUN(rd_by_ias_buffered) PSEUDOFUN(rd_by_ibu_buffered) PSEUDOFUN(rd_by_ibs_buffered) PSEUDOFUN(rd_by_icu_buffered) PSEUDOFUN(rd_by_ics_buffered) PSEUDOFUN(rd_by_iau8_buffered)
PSEUDOFUN(rd_by_array_iau8_buffered)
PSEUDOFUN(wr_by_iau_buffered) PSEUDOFUN(wr_by_ias_buffered) PSEUDOFUN(wr_by_ibu_buffered) PSEUDOFUN(wr_by_ibs_buffered) PSEUDOFUN(wr_by_icu_buffered) PSEUDOFUN(wr_by_ics_buffered) PSEUDOFUN(wr_by_iau8_buffered)
PSEUDOFUN(wr_by_array_iau8_buffered)
#if defined(KEYBOARD) || defined(MAYBE_NEXTAPP)
PSEUDOFUN(rd_ch_keyboard)
#endif
#if defined(MAYBE_NEXTAPP)
PSEUDOFUN(wr_ch_terminal) PSEUDOFUN(rd_ch_terminal)
#endif
#if defined(UNIX) || defined(MSDOS) || defined(AMIGAOS) || defined(RISCOS)
PSEUDOFUN(wr_ch_terminal1) PSEUDOFUN(rd_ch_terminal1) PSEUDOFUN(wr_ss_terminal1)
#ifdef MSDOS
PSEUDOFUN(wr_ch_terminal2) PSEUDOFUN(rd_ch_terminal2) PSEUDOFUN(wr_ss_terminal2)
#endif
#if defined(GNU_READLINE) || defined(MAYBE_NEXTAPP)
PSEUDOFUN(wr_ch_terminal3) PSEUDOFUN(rd_ch_terminal3) PSEUDOFUN(wr_ss_terminal3)
#endif
#endif
#ifdef SCREEN
PSEUDOFUN(wr_ch_window)
#endif
#ifdef PRINTER
PSEUDOFUN(wr_ch_printer)
#endif

