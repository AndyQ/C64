/*
 archdep.m -- iOS glue code for Vice
 Copyright (C) 2019 Dieter Baron
 
 This file is part of C64, a Commodore 64 emulator for iOS, based on VICE.
 The authors can be contacted at <c64@spiderlab.at>
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 02111-1307  USA.
*/

#include <errno.h>
#include <string.h>
#include <stdlib.h>

#include "archdep.h"
#include "archdep_defs.h"
#include "fullscreen.h"
#include "lib.h"
#include "util.h"
#include "resources.h"
#include "autostart-prg.h"
#include "machine.h"
#include "sid.h"

#import "ViceThread.h"
#import "ViceThreadC.h"

char *bundle_directory;

/** \brief  Generate a list of search paths for VICE system files
 *
 * \param[in]   emu_id  emulator ID (ie 'C64 or 'VSID')
 *
 * \return  heap-allocated string, to be freed by the caller
 */
char *archdep_default_sysfile_pathlist(const char *emu_id) {
    char *paths[] = {
        archdep_join_paths(bundle_directory, "vice", emu_id, NULL),
        archdep_join_paths(bundle_directory, "vice", "DRIVES", NULL),
        archdep_join_paths(bundle_directory, "vice", "PRINTER", NULL),
        NULL
    };
    
    char *path = util_strjoin((const char **)paths, ARCHDEP_FINDPATH_SEPARATOR_STRING);
    
    for (int i = 0; paths[i] != NULL; i++) {
        lib_free(paths[i]);
    }
    
    return path;
}

/** \brief  Free the internal copy of the sysfile pathlist
 *
 * Call on emulator exit
 */
void archdep_default_sysfile_pathlist_free(void) {
}


/** \brief  Write log message to stdout
 *
 * param[in]    level_string    log level string
 * param[in]    txt             log message
 *
 * \note    Shamelessly copied from unix/archdep.c
 *
 * \return  0 on success, < 0 on failure
 */
int archdep_default_logger(const char *level_string, const char *txt) {
    return 0;
}


/** \brief  Arch-dependent init
 *
 * \param[in]   argc    pointer to argument count
 * \param[in]   argv    argument vector
 *
 * \return  0
 */
int archdep_init(int *argc, char **argv) {
    return 0;
}


FILE *archdep_mkstemp_fd(char **filename, const char *mode) {
    return NULL;
}


int archdep_spawn(const char *name, char **argv, char **pstdout_redir, const char *stderr_redir) {
    errno = EOPNOTSUPP;
    return -1;
}

/** \brief  Generate path to the default RTC file
 *
 * \return  path to default RTC file, must be freed with lib_free()
 */
char *archdep_default_rtc_file_name(void)
{
    return archdep_join_paths(viceThread.machine.directoryURL.path.UTF8String, ARCHDEP_VICE_RTC_NAME, NULL);
}


/** \brief  Architecture-dependent shutdown hanlder
 */
void archdep_shutdown(void) {
}




void fullscreen_capability(struct cap_fullscreen_s *cap_fullscreen) {
}


/** \brief  Exit handler
 */
void main_exit(void) {
}


/** \brief  Initialize signal handling
 *
 *  Used once at init time to setup all signal handlers.
 *
 *  \param[in]  do_core_dumps   do core dumps. appearantly
 */void signals_init(int do_core_dumps) {
}

typedef void (*atexit_function_t)(void);

static atexit_function_t atexit_functions[32];
static int n_atexit_functions = 0;

/** \brief  Register \a function to be called on exit() or return from main
 *
 * Wrapper to work around Windows not handling the C library's atexit()
 * mechanism properly
 *
 * \param[in]   function    function to call at exit
 *
 * \return  0 on success, 1 on failure
 */
int archdep_vice_atexit(void (*function)(void))
{
    atexit_functions[n_atexit_functions++] = function;
    return 0;
}


/** \brief  Wrapper around exit()
 *
 * \param[in]   excode  exit code
 */
void archdep_vice_exit(int excode)
{
    while (n_atexit_functions > 0) {
        atexit_functions[--n_atexit_functions]();
    }
    
    printf("exit %d\n", excode);
    
    [NSThread exit];
}

void archdep_set_resources(void) {
    resources_set_int("SFXSoundExpander", 0);
    
    [viceThread.machine viceSetResources];
}

int archdep_late_init(void) {
//    archdep_set_resources();
    return 0;
}

#include "drive.h"

const char *drive_get_status(int unit) {
    static char buffer[0x30];
    int length = drive_context[unit - 8]->drive->drive_ram[0x0249] - 0xd4;
    if (length < 0) {
        length = 0;
    }
    memcpy(buffer, drive_context[unit - 8]->drive->drive_ram + 0x02d5, length);
    buffer[length] = '\0';
    return buffer;
}

void drive_set_id(int unit, uint8_t id1, uint8_t id2) {
    uint8_t id[2] = { id1, id2 };
    drive_set_initial_disk_id(unit - 8, id);
}

