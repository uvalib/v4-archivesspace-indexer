#
# Build extractor tool then run it. Convert output and combine. Upload to S3
#

MVN_CMD = mvn
GIT_CMD = git
JAVA_CMD = java
JAVA_OPTS = -Xms512M -Xmx512M
AWS_SYNC_CMD = aws s3 sync
YEAR = `date +%Y`
INDEX_DIR=results/index-v4

content: source update build dirs copy_config extract

source: archivesspace-virgo

archivesspace-virgo:
	$(GIT_CMD) clone https://github.com/uvalib/archivesspace-virgo.git

update:
	cd archivesspace-virgo; $(GIT_CMD) pull

build: archivesspace-virgo
	cd archivesspace-virgo; $(MVN_CMD) clean install dependency:copy-dependencies -DskipTests  &> ../maven_make.out

dirs:
	mkdir -p results/catalog/xml
	mkdir -p results/logs
	mkdir -p results/marc
	mkdir -p $(INDEX_DIR)

copy_config:
	cp config/indexer.properties config.properties
	-rm -rf $(INDEX_DIR)/*

extract:
	$(JAVA_CMD) $(JAVA_OPTS) -cp archivesspace-virgo/target/as-to-virgo-1.0-SNAPSHOT.jar:archivesspace-virgo/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecords

upload-staging:
	$(AWS_SYNC_CMD) $(INDEX_DIR)/ s3://virgo4-ingest-staging-inbound/doc-update/default/$(YEAR)/aspace/ --exact-timestamps --exclude "*" --include "*.xml"

upload-production:
	$(AWS_SYNC_CMD) $(INDEX_DIR)/ s3://virgo4-ingest-production-inbound/doc-update/default/$(YEAR)/aspace/ --exact-timestamps --exclude "*" --include "*.xml"

year:
	echo $(YEAR)
#
# end of file
#
