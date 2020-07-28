import os
import fcntl


class FileLock:
    def __init__(self, path):
        # Open the file and acquire a lock on the file before operating
        self.file = open(path, "a+")
        # Get an exclusive lock (EX), non-blocking (NB)
        try:
            fcntl.flock(self.file, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except OSError as exc:
            raise Exception(f"Failed to acquire exclusive lock file {path}") from exc
        # Clean lock file content
        self.file.truncate(0)

    # Return the opened file object (knowing a lock has been obtained).
    def __enter__(self, *args, **kwargs):
        return self.file

    # Unlock the file and close the file object.
    def __exit__(self, exc_type=None, exc_value=None, traceback=None):
        # Flush to make sure all buffered contents are written to file.
        self.file.flush()
        os.fsync(self.file.fileno())
        # Release the lock on the file.
        fcntl.flock(self.file, fcntl.LOCK_UN)
        self.file.close()
