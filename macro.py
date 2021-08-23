import math

def define_env(env):
    """
    This is the hook for defining variables, macros and filters

    - variables: the dictionary that contains the environment variables
    - macro: a decorator function, to declare a macro.
    - filter: a function with one of more arguments,
        used to perform a transformation
    """

    # NOTE: you may also treat env.variables as a namespace,
    #       with the dot notation:
    env.variables.snippet_full_path = "Meant to be used with snppiets in the same folder with markdown file"

    @env.macro
    def snippet_full_path(x: str):
        return '/'.join([
            env.page.file.src_path.rsplit('/', 1)[0],
            x
        ])