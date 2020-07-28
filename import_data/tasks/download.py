import logging
import os
from datetime import datetime

logger = logging.getLogger(__name__)


def needs_to_download(ctx, file, max_age=None):
    """
    Check if "file" should be downloaded
    because it doesn't exist, or is older than "max_age"
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

    logger.warning(f"file {file} already exists, we don't need to download it again")
    return False


def download_file(ctx, file, url, **kwargs):
    if not needs_to_download(ctx, file, **kwargs):
        return
    ctx.run(f"wget --progress=dot:giga -O {file} {url}")
