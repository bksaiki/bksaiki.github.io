"""
copy_papers.py: copies papers from `papers-repo` to website
"""

import enum
import shutil

from argparse import ArgumentParser
from pathlib import Path

THIS_DIR = Path(__file__).parent.resolve()
PAPERS_REPO = THIS_DIR / 'papers-repo'
DEST_PATH = THIS_DIR / 'papers'

class Category(enum.Enum):
    NOTES = 0
    CLASS = 1

    def as_path(self, base: Path):
        match self:
            case Category.NOTES:
                return base / 'notes'
            case Category.CLASS:
                return base / 'class'
            case _:
                raise ValueError(f'unknown: {self}')


MANIFEST: dict[str, Category] = {
    'computer_numbers_systems': Category.CLASS,
    'construction_of_numbers': Category.NOTES,
    'folland-real-analysis': Category.NOTES,
    'gamelin': Category.NOTES,
    'hungerford-abstract-algebra': Category.NOTES,
    'numerical-analysis': Category.NOTES,
    'probability': Category.NOTES,
    'rewriting_blog': Category.CLASS
}


if __name__ == '__main__':
    parser = ArgumentParser(description='copy papers from papers-repo to website')
    args = parser.parse_args()

    for name, cat in MANIFEST.items():
        src_dir = PAPERS_REPO / name
        dest_dir = cat.as_path(DEST_PATH) / name

        # create destination directory
        dest_dir.mkdir(parents=True, exist_ok=True)

        # copy over any pdf from source directory
        for src_file in src_dir.glob('*.pdf'):
            dest_file = dest_dir / src_file.name
            shutil.copy2(src_file, dest_file)
            print(f'copied `{src_file}` to `{dest_file}`')
