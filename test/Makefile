
test: build/NSDateFormatterTest
	./$<

# NSDateFormatterTest:NSDateFormatterTest.m
# 	gcc $< -o $@

build/%:%.m build
	gcc $< -o $@ -framework Cocoa

build:
	mkdir build
