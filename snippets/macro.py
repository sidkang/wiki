def define_env(env):
    """
    This is the hook for declaring variables, macros and filters (new form)
    """

    from base64 import b64encode
    import io
    import warnings
    import matplotlib.pyplot as plt
    import matplotlib as mpl

    warnings.filterwarnings('ignore', '.*Matplotlib is currently using agg.*', )

    env.variables.docs_dir_name = env.variables.config['docs_dir'].rsplit('/', 1)[-1]

    @env.macro
    def snippet_full_path(x: str):
        return '/'.join([
            env.page.file.src_path.rsplit('/', 1)[0],
            x
        ])

    @env.macro
    def embed_plot(script_name, alt_text='', width=640, height=480):

        mpl.rcParams['figure.dpi'] = 500
        mpl.rcParams['savefig.dpi'] = 500
        plt.style.use('seaborn-poster')

        # sns.set_theme()

        plt.switch_backend('Agg')
        d = dict(locals(), **globals())

        path_to_script = '/'.join([
            env.variables.docs_dir_name,
            env.page.file.src_path.rsplit('/', 1)[0],
            'scripts',
            script_name
        ])

        exec(open(path_to_script).read(), d, d)

        buf = io.BytesIO()
        plt.tight_layout()
        plt.savefig(buf, format="png")
        data = b64encode(buf.getbuffer()).decode("ascii")
        return f"<img alt='{alt_text}' width='{width}' height='{height}' src='data:image/png;base64,{data}'/>"
