from simulator import get_route


def main():
    start = (18.0686, 59.3293)
    end = (18.0900, 59.3400)
    coordinates = get_route(start, end)

    print(f"Route points: {len(coordinates)}")

    for longitude, latitude in coordinates[:5]:
        print(latitude, longitude)


if __name__ == "__main__":
    main()