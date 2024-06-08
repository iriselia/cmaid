// Pre-compiled & Force Included Headers

// Utility
#include <stdio.h>

#define QUOTEME(M)       #M
#define INHERITS(M)  QUOTEME(M##.pro.h)
//#include INHERITS(PrivateLib)

// Local Public
#include "PublicDLL.pub.h"
