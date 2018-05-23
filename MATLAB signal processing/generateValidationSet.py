import glob, os
from subprocess import call
os.chdir("validation")
for file in glob.glob("*.hea"):
    record=file[:-4]
    call(["/Users/mk/cinc2017/next.sh", record])