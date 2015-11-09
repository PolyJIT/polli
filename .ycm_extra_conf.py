import os
import ycm_core

def DirectoryOfThisScript():
    return os.path.dirname(os.path.abspath('__file__'))


def root():
    return "{0}/../../../../".format(DirectoryOfThisScript())


def pollyRoot():
    return "{0}/tools/polly".format(root())


def polly_inc(sub):
    return "{0}/{1}".format(pollyRoot(), sub)


def polli_inc(sub):
    return "{0}/tools/polli/{1}".format(pollyRoot(), sub)


def llvm_inc(sub):
    return "{0}/{1}".format(root(), sub)


def get_system_includes():
    from plumbum.cmd import echo, clang
    _, _, stderr  = (echo | clang['-v', '-E', '-x', 'c++', '-']).run()
    l = stderr.split('\n')

    idx_begin = 0
    idx_end = 0

    for i in range(len(l)):
        if l[i] == '#include "..." search starts here:':
            idx_begin = i+1
        if l[i] == "End of search list.":
            idx_end = i-1

    res = []
    for i in range(idx_begin+1, idx_end):
        res += ["-isystem", l[i].lstrip()]
    return res


flags = [
    "-std=c++14",
    "-stdlib=libstdc++",
    "-DENABLE_GTEST",
    "-DFMT_HEADER_ONLY",
    "-D_DEBUG",
    "-D_GNU_SOURCE",
    "-D__STDC_CONSTANT_MACROS",
    "-D__STDC_FORMAT_MACROS",
    "-D__STDC_LIMIT_MACROS",
    "-Wall",
    "-W",
    "-Wno-unused-parameter",
    "-Wwrite-strings",
    "-Wcast-qual",
    "-Wmissing-field-initializers",
    "-Wno-long-long",
    "-Wcovered-switch-default",
    "-Wnon-virtual-dtor",
    "-fcolor-diagnostics",
    "-ffunction-sections",
    "-fdata-sections",
    "-fno-omit-frame-pointer",
    "-fPIC",
    "-pedantic",
    "-fno-rtti",
    "-fno-exceptions",
    "-pthread"
]
flags = flags + get_system_includes()
flags = flags + [
    "-I", polli_inc("include"),
    "-I", polli_inc("external"),
    "-I", polly_inc("include"),
    "-I", polly_inc("include/external"),
    "-I", polly_inc("lib/External/isl"),
    "-I", polly_inc("lib/External/isl/imath"),
    "-I", polly_inc("lib/External/isl/include"),
    "-I", polly_inc("lib/JSON/include"),
    "-I", llvm_inc("include"),
    "-I", root() + "build/include",
    "-I", u"/usr/include"
]


compilation_database_folder = DirectoryOfThisScript()
if os.path.exists( compilation_database_folder ):
    database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
    database = None


def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag):]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

            if new_flag:
                new_flags.append(new_flag)
    return new_flags

def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def FlagsForFile(filename):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = GetCompilationInfoForFile( filename )
    if not compilation_info:
      return None

    final_flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )

    # NOTE: This is just for YouCompleteMe; it's highly likely that your project
    # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
    # ycm_extra_conf IF YOU'RE NOT 100% SURE YOU NEED IT.
    try:
      final_flags.remove( '-stdlib=libc++' )
    except ValueError:
      pass
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )


  return {
      'flags': final_flags,
      'do_cache': True
  }
