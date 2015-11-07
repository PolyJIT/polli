import os


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


flags = [
    "-std=c++14",
    "-DENABLE_GTEST",
    "-DFMT_HEADER_ONLY",
    "-D_DEBUG",
    "-D_GNU_SOURCE",
    "-D__STDC_CONSTANT_MACROS",
    "-D__STDC_FORMAT_MACROS",
    "-D__STDC_LIMIT_MACROS",
    "-Wall",
    "-pedantic",
    "-fno-rtti",
    "-pthread",
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
    "-I", "/usr/include"
]


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


def FlagsForFile(filename):
    return {
        'flags': flags,
        'do_cache': True
    }
