.PHONY: build
default: build

AWS := Vendor/aws
AWS_COMMON_FLAGS := --storage-class REDUCED_REDUNDANCY
AWS_IMAGE_CACHE_CONTROL := --cache-control "max-age=1209600,public"

clean:

build:
	@swift run robb.swift

sync:
	@$(AWS) s3 sync $(AWS_COMMON_FLAGS) --exclude '*DS_Store' --exclude '*.jpg' --exclude '*.html' Site s3://robb.is

	@$(AWS) s3 sync $(AWS_COMMON_FLAGS) $(AWS_IMAGE_CACHE_CONTROL) --exclude '*DS_Store' --exclude '*' --include '*.jpg' Site s3://robb.is

	@$(AWS) s3 cp $(AWS_COMMON_FLAGS) 'Site/index.html' 's3://robb.is/index.html'

	@for f in `find Site -type f -name 'index.html' -mindepth 2`; do \
		TARGET=$${f/Site\//}; \
		TARGET=$${TARGET/\/index.html/}; \
		ESCAPED=$${TARGET/❤/%E2%9D%A4}; \
		$(AWS) s3 cp $(AWS_COMMON_FLAGS) "$$f" "s3://robb.is/$$TARGET"; \
		$(AWS) s3 cp $(AWS_COMMON_FLAGS) "$$f" "s3://robb.is/$$TARGET/index.html" --website-redirect "//robb.is/$$ESCAPED"; \
	done

	@for f in `find Site -type f -name '*.html' ! -name 'index.html'`; do \
		TARGET=$${f/Site\//}; \
		TARGET=$${TARGET/\.html/}; \
		ESCAPED=$${TARGET/❤/%E2%9D%A4}; \
		$(AWS) s3 cp $(AWS_COMMON_FLAGS) "$$f" "s3://robb.is/$$TARGET"; \
		$(AWS) s3 cp $(AWS_COMMON_FLAGS) "$$f" "s3://robb.is/$$TARGET/index.html" --website-redirect "//robb.is/$$ESCAPED"; \
	done
