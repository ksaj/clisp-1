/*
 * Copyright (C) 1999-2000 Free Software Foundation, Inc.
 * This file is part of the GNU LIBICONV Library.
 *
 * The GNU LIBICONV Library is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * The GNU LIBICONV Library is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU LIBICONV Library; see the file COPYING.LIB.
 * If not, write to the Free Software Foundation, Inc., 59 Temple Place -
 * Suite 330, Boston, MA 02111-1307, USA.
 */

/*
 * MacThai
 */

static const unsigned short mac_thai_2uni[128] = {
  /* 0x80 */
  0x00ab, 0x00bb, 0x2026, 0xf88c, 0xf88f, 0xf892, 0xf895, 0xf898,
  0xf88b, 0xf88e, 0xf891, 0xf894, 0xf897, 0x201c, 0x201d, 0xf899,
  /* 0x90 */
  0xfffd, 0x2022, 0xf884, 0xf889, 0xf885, 0xf886, 0xf887, 0xf888,
  0xf88a, 0xf88d, 0xf890, 0xf893, 0xf896, 0x2018, 0x2019, 0xfffd,
  /* 0xa0 */
  0x00a0, 0x0e01, 0x0e02, 0x0e03, 0x0e04, 0x0e05, 0x0e06, 0x0e07,
  0x0e08, 0x0e09, 0x0e0a, 0x0e0b, 0x0e0c, 0x0e0d, 0x0e0e, 0x0e0f,
  /* 0xb0 */
  0x0e10, 0x0e11, 0x0e12, 0x0e13, 0x0e14, 0x0e15, 0x0e16, 0x0e17,
  0x0e18, 0x0e19, 0x0e1a, 0x0e1b, 0x0e1c, 0x0e1d, 0x0e1e, 0x0e1f,
  /* 0xc0 */
  0x0e20, 0x0e21, 0x0e22, 0x0e23, 0x0e24, 0x0e25, 0x0e26, 0x0e27,
  0x0e28, 0x0e29, 0x0e2a, 0x0e2b, 0x0e2c, 0x0e2d, 0x0e2e, 0x0e2f,
  /* 0xd0 */
  0x0e30, 0x0e31, 0x0e32, 0x0e33, 0x0e34, 0x0e35, 0x0e36, 0x0e37,
  0x0e38, 0x0e39, 0x0e3a, 0xfeff, 0x200b, 0x2013, 0x2014, 0x0e3f,
  /* 0xe0 */
  0x0e40, 0x0e41, 0x0e42, 0x0e43, 0x0e44, 0x0e45, 0x0e46, 0x0e47,
  0x0e48, 0x0e49, 0x0e4a, 0x0e4b, 0x0e4c, 0x0e4d, 0x2122, 0x0e4f,
  /* 0xf0 */
  0x0e50, 0x0e51, 0x0e52, 0x0e53, 0x0e54, 0x0e55, 0x0e56, 0x0e57,
  0x0e58, 0x0e59, 0x00ae, 0x00a9, 0xfffd, 0xfffd, 0xfffd, 0xfffd,
};

static int
mac_thai_mbtowc (conv_t conv, ucs4_t *pwc, const unsigned char *s, int n)
{
  unsigned char c = *s;
  if (c < 0x80) {
    *pwc = (ucs4_t) c;
    return 1;
  }
  else {
    unsigned short wc = mac_thai_2uni[c-0x80];
    if (wc != 0xfffd) {
      *pwc = (ucs4_t) wc;
      return 1;
    }
  }
  return RET_ILSEQ;
}

static const unsigned char mac_thai_page00[32] = {
  0xa0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0xa0-0xa7 */
  0x00, 0xfb, 0x00, 0x80, 0x00, 0x00, 0xfa, 0x00, /* 0xa8-0xaf */
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0xb0-0xb7 */
  0x00, 0x00, 0x00, 0x81, 0x00, 0x00, 0x00, 0x00, /* 0xb8-0xbf */
};
static const unsigned char mac_thai_page0e[96] = {
  0x00, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, /* 0x00-0x07 */
  0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf, /* 0x08-0x0f */
  0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7, /* 0x10-0x17 */
  0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, /* 0x18-0x1f */
  0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, /* 0x20-0x27 */
  0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf, /* 0x28-0x2f */
  0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, /* 0x30-0x37 */
  0xd8, 0xd9, 0xda, 0x00, 0x00, 0x00, 0x00, 0xdf, /* 0x38-0x3f */
  0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, /* 0x40-0x47 */
  0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0x00, 0xef, /* 0x48-0x4f */
  0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, /* 0x50-0x57 */
  0xf8, 0xf9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x58-0x5f */
};
static const unsigned char mac_thai_page20[32] = {
  0x00, 0x00, 0x00, 0xdc, 0x00, 0x00, 0x00, 0x00, /* 0x08-0x0f */
  0x00, 0x00, 0x00, 0xdd, 0xde, 0x00, 0x00, 0x00, /* 0x10-0x17 */
  0x9d, 0x9e, 0x00, 0x00, 0x8d, 0x8e, 0x00, 0x00, /* 0x18-0x1f */
  0x00, 0x00, 0x91, 0x00, 0x00, 0x00, 0x82, 0x00, /* 0x20-0x27 */
};
static const unsigned char mac_thai_pagef8[32] = {
  0x00, 0x00, 0x00, 0x00, 0x92, 0x94, 0x95, 0x96, /* 0x80-0x87 */
  0x97, 0x93, 0x98, 0x88, 0x83, 0x99, 0x89, 0x84, /* 0x88-0x8f */
  0x9a, 0x8a, 0x85, 0x9b, 0x8b, 0x86, 0x9c, 0x8c, /* 0x90-0x97 */
  0x87, 0x8f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, /* 0x98-0x9f */
};

static int
mac_thai_wctomb (conv_t conv, unsigned char *r, ucs4_t wc, int n)
{
  unsigned char c = 0;
  if (wc < 0x0080) {
    *r = wc;
    return 1;
  }
  else if (wc >= 0x00a0 && wc < 0x00c0)
    c = mac_thai_page00[wc-0x00a0];
  else if (wc >= 0x0e00 && wc < 0x0e60)
    c = mac_thai_page0e[wc-0x0e00];
  else if (wc >= 0x2008 && wc < 0x2028)
    c = mac_thai_page20[wc-0x2008];
  else if (wc == 0x2122)
    c = 0xee;
  else if (wc >= 0xf880 && wc < 0xf8a0)
    c = mac_thai_pagef8[wc-0xf880];
  else if (wc == 0xfeff)
    c = 0xdb;
  if (c != 0) {
    *r = c;
    return 1;
  }
  return RET_ILSEQ;
}
