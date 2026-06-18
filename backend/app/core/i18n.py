from typing import Optional

SUPPORTED_LANGS = ("en", "ru", "kk")
DEFAULT_LANG = "en"


def resolve_lang(lang_param: Optional[str], accept_language: Optional[str]) -> str:
    """Priority: ?lang= query param > Accept-Language header > 'en'."""
    candidate = None
    if lang_param:
        candidate = lang_param.strip().lower().split("-")[0]
    elif accept_language:
        first_token = accept_language.split(",")[0].split(";")[0].strip()
        candidate = first_token.lower().split("-")[0]
    return candidate if candidate in SUPPORTED_LANGS else DEFAULT_LANG


def pick_translation(translations, lang: str):
    """Fallback chain: requested lang → 'en' → first available → None."""
    index = {t.lang: t for t in translations}
    return (
        index.get(lang)
        or index.get(DEFAULT_LANG)
        or (translations[0] if translations else None)
    )
