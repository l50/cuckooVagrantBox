import json as json
from os import listdir
from os.path import isfile, join

path = './'
file_list = [ f for f in listdir(path) if isfile(join(path,f)) ]

for fi in file_list:
    with open(fi) as f:
        json_data = f.read()
        data = json.loads(json_data)
        if data['strings'] != None:
            del data['strings']

    with open(fi, "w") as f:
        write_data = json.dumps(data, indent=2)
        f.write(write_data)
