TOP=..
include $(TOP)/configure/CONFIG
#=======================================

# Install .dbd and .db files
DB += zfcntrl.db
DB += zfcntrl_axis.db
DBD += zfcntrl.dbd

# Sequence file
LIBRARY_IOC = zfcntrl
zfcntrl_SRCS += zero_field.st
zfcntrl_LIBS += seq pv
zfcntrl_LIBS += $(EPICS_BASE_IOC_LIBS)

#=======================================
include $(TOP)/configure/RULES
