test:
	casperjs test tests

test-i:
	rm -f tests/failure.png \
		; casperjs test tests \
		|| open tests/failure.png

.PHONY: test test-i