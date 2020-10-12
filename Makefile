#
# Build extractor tool then run it. Convert output and combine. Upload to S3
#

MVN_CMD = mvn
GIT_CMD = git
JAVA_CMD = java
JAVA_OPTS = -Xms512M -Xmx512M

all: source update build dirs extract upload-staging # upload-production

source: source/
	$(GIT_CMD) clone git@github.com:uvalib/archivesspace-virgo.git source

update:
	cd source; $(GIT_CMD) pull

build: source/
	cd source; $(MVN_CMD) clean install dependency:copy-dependencies -DskipTests

dirs:
	mkdir -p results/catalog/xml
	mkdir -p results/index
	mkdir -p results/logs
	mkdir -p results/marc

extract:
	cp config/indexer.properties config.properties
	-rm index-generation.log
	$(JAVA_CMD) $(JAVA_OPTS) -cp source/target/as-to-virgo-1.0-SNAPSHOT.jar:source/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecords

upload-staging:
	$(JAVA_CMD) $(JAVA_OPTS) -cp source/target/as-to-virgo-1.0-SNAPSHOT.jar:source/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecordsForV4 config/upload-staging.properties

upload-production:
	$(JAVA_CMD) $(JAVA_OPTS) -cp source/target/as-to-virgo-1.0-SNAPSHOT.jar:source/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecordsForV4 config/upload-production.properties

#
# end of file
#
