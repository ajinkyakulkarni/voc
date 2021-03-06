/* voc 1.95 [2016/08/23] for gcc LP64 on cygwin xtspkaSfF */
#include "SYSTEM.h"




static void Reals_BytesToHex (SYSTEM_BYTE *b, LONGINT b__len, SYSTEM_BYTE *d, LONGINT d__len);
export void Reals_Convert (REAL x, INTEGER n, CHAR *d, LONGINT d__len);
export void Reals_ConvertH (REAL y, CHAR *d, LONGINT d__len);
export void Reals_ConvertHL (LONGREAL x, CHAR *d, LONGINT d__len);
export void Reals_ConvertL (LONGREAL x, INTEGER n, CHAR *d, LONGINT d__len);
export INTEGER Reals_Expo (REAL x);
export INTEGER Reals_ExpoL (LONGREAL x);
export void Reals_SetExpo (REAL *x, INTEGER ex);
export REAL Reals_Ten (INTEGER e);
export LONGREAL Reals_TenL (INTEGER e);
static CHAR Reals_ToHex (INTEGER i);


REAL Reals_Ten (INTEGER e)
{
	REAL _o_result;
	LONGREAL r, power;
	r = (LONGREAL)1;
	power = (LONGREAL)10;
	while (e > 0) {
		if (__ODD(e)) {
			r = r * power;
		}
		power = power * power;
		e = __ASHR(e, 1);
	}
	_o_result = r;
	return _o_result;
}

LONGREAL Reals_TenL (INTEGER e)
{
	LONGREAL _o_result;
	LONGREAL r, power;
	r = (LONGREAL)1;
	power = (LONGREAL)10;
	for (;;) {
		if (__ODD(e)) {
			r = r * power;
		}
		e = __ASHR(e, 1);
		if (e <= 0) {
			_o_result = r;
			return _o_result;
		}
		power = power * power;
	}
	__RETCHK;
}

INTEGER Reals_Expo (REAL x)
{
	INTEGER _o_result;
	INTEGER i;
	__GET((LONGINT)(SYSTEM_ADDRESS)&x + 2, i, INTEGER);
	_o_result = __MASK(__ASHR(i, 7), -256);
	return _o_result;
}

void Reals_SetExpo (REAL *x, INTEGER ex)
{
	CHAR c;
	__GET((LONGINT)(SYSTEM_ADDRESS)x + 3, c, CHAR);
	__PUT((LONGINT)(SYSTEM_ADDRESS)x + 3, (CHAR)(__ASHL(__ASHR((int)c, 7), 7) + __MASK(__ASHR(ex, 1), -128)), CHAR);
	__GET((LONGINT)(SYSTEM_ADDRESS)x + 2, c, CHAR);
	__PUT((LONGINT)(SYSTEM_ADDRESS)x + 2, (CHAR)(__MASK((int)c, -128) + __ASHL(__MASK(ex, -2), 7)), CHAR);
}

INTEGER Reals_ExpoL (LONGREAL x)
{
	INTEGER _o_result;
	INTEGER i;
	__GET((LONGINT)(SYSTEM_ADDRESS)&x + 6, i, INTEGER);
	_o_result = __MASK(__ASHR(i, 4), -2048);
	return _o_result;
}

void Reals_ConvertL (LONGREAL x, INTEGER n, CHAR *d, LONGINT d__len)
{
	LONGINT i, j, k;
	if (x < (LONGREAL)0) {
		x = -x;
	}
	k = 0;
	if (n > 9) {
		i = (int)__ENTIER(x / (LONGREAL)(LONGREAL)1000000000);
		j = (int)__ENTIER(x - i * (LONGREAL)1000000000);
		if (j < 0) {
			j = 0;
		}
		while (k < 9) {
			d[__X(k, d__len)] = (CHAR)(__MOD(j, 10) + 48);
			j = __DIV(j, 10);
			k += 1;
		}
	} else {
		i = (int)__ENTIER(x);
	}
	while (k < (int)n) {
		d[__X(k, d__len)] = (CHAR)(__MOD(i, 10) + 48);
		i = __DIV(i, 10);
		k += 1;
	}
}

void Reals_Convert (REAL x, INTEGER n, CHAR *d, LONGINT d__len)
{
	Reals_ConvertL(x, n, (void*)d, d__len);
}

static CHAR Reals_ToHex (INTEGER i)
{
	CHAR _o_result;
	if (i < 10) {
		_o_result = (CHAR)(i + 48);
		return _o_result;
	} else {
		_o_result = (CHAR)(i + 55);
		return _o_result;
	}
	__RETCHK;
}

static void Reals_BytesToHex (SYSTEM_BYTE *b, LONGINT b__len, SYSTEM_BYTE *d, LONGINT d__len)
{
	INTEGER i;
	LONGINT l;
	CHAR by;
	i = 0;
	l = b__len;
	while ((int)i < l) {
		by = __VAL(CHAR, b[__X(i, b__len)]);
		d[__X(__ASHL(i, 1), d__len)] = Reals_ToHex(__ASHR((int)by, 4));
		d[__X(__ASHL(i, 1) + 1, d__len)] = Reals_ToHex(__MASK((int)by, -16));
		i += 1;
	}
}

void Reals_ConvertH (REAL y, CHAR *d, LONGINT d__len)
{
	Reals_BytesToHex((void*)&y, ((LONGINT)(4)), (void*)d, d__len * ((LONGINT)(1)));
}

void Reals_ConvertHL (LONGREAL x, CHAR *d, LONGINT d__len)
{
	Reals_BytesToHex((void*)&x, ((LONGINT)(8)), (void*)d, d__len * ((LONGINT)(1)));
}


export void *Reals__init(void)
{
	__DEFMOD;
	__REGMOD("Reals", 0);
/* BEGIN */
	__ENDMOD;
}
