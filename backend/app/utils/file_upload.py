import os
import shutil
import uuid
from fastapi import UploadFile, HTTPException
from app.core.config import settings


def save_upload(file: UploadFile, task_id: int) -> str:
    task_dir = os.path.join(settings.UPLOAD_DIR, str(task_id))
    os.makedirs(task_dir, exist_ok=True)

    ext      = os.path.splitext(file.filename or "")[1]
    filename = f"{uuid.uuid4()}{ext}"
    dest     = os.path.join(task_dir, filename)

    with open(dest, "wb") as out_file:
        shutil.copyfileobj(file.file, out_file)

    size_mb = os.path.getsize(dest) / (1024 * 1024)
    if size_mb > settings.MAX_FILE_SIZE_MB:
        os.remove(dest)
        raise HTTPException(status_code=413, detail=f"File exceeds the {settings.MAX_FILE_SIZE_MB}MB limit")

    return dest
