#
# Build extractor tool then run it. Convert output and combine. Upload to S3
#

MVN_CMD = mvn
GIT_CMD = git
JAVA_CMD = java

all: source update build dirs extract upload

source: source/
	$(GIT_CMD) clone git@github.com:uvalib/archivesspace-virgo.git source

update:
	cd source; $(GIT_CMD) pull

build: source/
	cd source; $(MVN_CMD) clean install dependency:copy-dependencies -DskipTests

dirs:
	mkdir -p results/logs
	mkdir -p results/marc
	mkdir -p results/catalog/xml

extract:
	cp config/config.properties .
	$(JAVA_CMD) -cp source/target/as-to-virgo-1.0-SNAPSHOT.jar:source/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecords

upload:
	cp config/config.properties .
	$(JAVA_CMD) -cp source/target/as-to-virgo-1.0-SNAPSHOT.jar:source/target/dependency/* edu.virginia.lib.indexing.tools.IndexRecordsForV4

#
# end of file
#
