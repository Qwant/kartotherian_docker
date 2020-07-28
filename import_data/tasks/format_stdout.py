import sys
from functools import wraps

from invoke import context


class PrefixedStream:
    """
    Wrapper class around a stream adding a prefix to each writen line.
    """

    def __init__(self, src_stream, prefix):
        self.prefix = prefix
        self.src_stream = src_stream
        self.buffer = ""

    def write(self, data):
        self.buffer += data
        self.flush()

    def flush(self):
        lines = self.buffer.split("\n")

        for line in lines[:-1]:
            self.src_stream.write("[{}] {}\n".format(self.prefix, line))

        self.buffer = lines[-1]
        self.src_stream.flush()


class PrefixedContext(context.Context):
    """
    Wrapper class around a pyinvoke context adding a prefix to each lines
    outputed by ctx.run(..).
    """

    def __init__(self, ctx, prefix):
        super().__init__(ctx.config)
        self.prefix = prefix

    def run(self, *args, **kwargs):
        return super().run(
            *args,
            **kwargs,
            out_stream=PrefixedStream(sys.stdout, self.prefix),
            err_stream=PrefixedStream(sys.stderr, self.prefix + ":ERR"),
        )


def format_stdout(fun):
    """
    Wrapper decorator around a task adding its name to each line outputed by
    ctx.run(..).
    """

    @wraps(fun)
    def upgraded_fun(ctx, *args, **kwargs):
        ctx = PrefixedContext(ctx, fun.__name__)
        fun(ctx, *args, **kwargs)

    return upgraded_fun
