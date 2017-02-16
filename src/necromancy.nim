# =======
# Imports
# =======

import os
import parseopt2

import "logger.nim"
import "termbox.nim"
import "bindings.nim"
import "preferences.nim"

# =====
# Types
# =====

type Subcommand {.pure.} = enum
  None,
  Help,
  Version,
  Configuration

# =========
# Functions
# =========

proc progName(): string =
  result = os.extractFilename(os.getAppFilename())

proc usage(): void = 
  quit(QuitSuccess)

proc versionInfo(): void =
  echo(progname() & " v0.1")
  quit(QuitSuccess)

# ===========================================
# this is the entry-point, there is no main()
# ===========================================

var command = Subcommand.None
var configuration_path = os.expandTilde(os.getEnv("NECROMANCY_CONFIG"))
var working_directory = os.getCurrentDir()
var enable_verbose_logging = false
var enable_debug_logging = false

for kind, key, value in parseopt2.getopt():
  case kind
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      command = Subcommand.Help
    of "version", "v":
      command = Subcommand.Version
    of "config":
      command = Subcommand.Configuration
      configuration_path = os.expandTilde(value)
    of "verbose":
      enable_verbose_logging = true
    of "debug":
      enable_debug_logging = true
    else:
      discard
  of cmdArgument:
    working_directory = os.expandTilde(key)
  else:
    discard

initiateLogger(enable_verbose_logging, enable_debug_logging)

Logger(Debug, "Parsing the passed commands...")
case command
of Subcommand.Version:
  versionInfo()
of Subcommand.Help:
  usage()
else:
  let config = loadPreferences(configuration_path)
  discard tb_init()
  var should_continue = true
  while should_continue:
    should_continue = processInput()
  tb_set_cursor(0,0)
  tb_shutdown()