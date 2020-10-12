#
# Run the ArchivesSpace indexer
#

# make the content to be uploaded
make content
res=$?
if [ $res -ne 0 ]; then
   echo "ERROR: during content creation, aborting"
   exit $res
fi

# and upload it
make upload-staging
#make upload-production

# all over
exit 0

#
# end of file
#
