import asyncio
import logging
from dataclasses import dataclass

import aiohttp

logger = logging.getLogger(__name__)

_NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse"
_USER_AGENT = "AsarServiceBot/1.0"
_TIMEOUT = aiohttp.ClientTimeout(total=10)
_MAX_RETRIES = 3
_RETRY_DELAY = 1.5


@dataclass
class GeoLocation:
    latitude: float
    longitude: float
    full_address: str
    city: str
    district: str | None
    region: str
    country: str
    postal_code: str | None


class GeocoderError(Exception):
    pass


async def reverse_geocode(latitude: float, longitude: float) -> GeoLocation:
    if not (-90 <= latitude <= 90) or not (-180 <= longitude <= 180):
        raise GeocoderError("Некорректные координаты")

    params = {
        "lat": str(latitude),
        "lon": str(longitude),
        "format": "json",
        "addressdetails": "1",
        "accept-language": "ru",
    }
    headers = {"User-Agent": _USER_AGENT}

    last_exc: Exception | None = None
    for attempt in range(_MAX_RETRIES):
        try:
            async with aiohttp.ClientSession(timeout=_TIMEOUT) as session:
                async with session.get(_NOMINATIM_URL, params=params, headers=headers) as resp:
                    if resp.status != 200:
                        raise GeocoderError(
                            f"Сервис геокодирования вернул ошибку {resp.status}"
                        )
                    data = await resp.json()

            addr = data.get("address", {})
            full_address = data.get("display_name", "")

            city: str = (
                addr.get("city")
                or addr.get("town")
                or addr.get("village")
                or addr.get("municipality")
                or ""
            )
            district: str | None = (
                addr.get("suburb")
                or addr.get("district")
                or addr.get("city_district")
            )
            region: str = (
                addr.get("state")
                or addr.get("region")
                or addr.get("province")
                or ""
            )
            country: str = addr.get("country") or ""
            postal_code: str | None = addr.get("postcode")

            logger.info(
                "Geocoded (%.6f, %.6f) → %s", latitude, longitude, full_address
            )

            return GeoLocation(
                latitude=latitude,
                longitude=longitude,
                full_address=full_address,
                city=city,
                district=district,
                region=region,
                country=country,
                postal_code=postal_code,
            )

        except GeocoderError:
            raise
        except asyncio.TimeoutError as exc:
            last_exc = exc
            logger.warning(
                "Geocoding timeout (attempt %d/%d)", attempt + 1, _MAX_RETRIES
            )
        except Exception as exc:
            last_exc = exc
            logger.warning(
                "Geocoding error (attempt %d/%d): %s", attempt + 1, _MAX_RETRIES, exc
            )

        if attempt < _MAX_RETRIES - 1:
            await asyncio.sleep(_RETRY_DELAY)

    raise GeocoderError(
        f"Не удалось получить адрес после {_MAX_RETRIES} попыток"
    ) from last_exc
