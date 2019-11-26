import logging
import os
from datetime import datetime

logger = logging.getLogger(__name__)

def needs_to_download(ctx, file, max_age=None):
    """
    check if a file already exists in the directory
    if it's the case, check if we need a more up to date file (by comparing the md5)
    and if so, clean the old file
    """
    if not os.path.isfile(file):
        return True

    if ctx.force_downloads:
        logger.info(f"'force_downloads' is set to true: existing file {file} will be ignored")
        return True

    if max_age is not None:
        existing_file_dt = datetime.utcfromtimestamp(os.path.getctime(file))
        if datetime.utcnow() - existing_file_dt > max_age:
            return True

    logger.warning(
        f"file {file} already exists, we don't need to download it again"
    )
    return False


def download_file(ctx, file, url, **kwargs):
    if not needs_to_download(ctx, file, **kwargs):
        return
    ctx.run(f"wget --progress=dot:giga -O {file} {url}")
