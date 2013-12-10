test:
	casperjs test tests

# Run tests with screen captures
test-i:
	rm -f tests/failure.png \
		; casperjs test tests --images=on \
		|| open tests/failure.png

test-ci:
	rm -f tests/failure.png \
		; casperjs test tests --images=on --no-colors

.PHONY: test test-i
