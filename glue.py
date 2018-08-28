import sys
import time
import json
import uuid
import bblfsh
import base64
import pathlib
import datetime
from subprocess import PIPE, Popen


# PARSER_MAP : maps from lang to parsers
PARSER_MAP = {
  'Shell': (
    'localhost:9432', 'bash'),
  'Go': (
    'localhost:9433', 'go'),
  'Java': (
    'localhost:9434', 'java'),
  'JavaScript': (
    'localhost:9435', 'javascript'),
  'PHP': (
    'localhost:9436', 'php'),
  'Python': (
    'localhost:9437', 'python'),
  'Ruby': (
    'localhost:9438', 'ruby'),
  # 'TypeScript': (
  #   'unix:///tmp/typescript', 'typescript')
}

# Load data from stdin (generated by enry)
enry_data = json.load(sys.stdin)

# Now add in UASTs
for supported_lang in PARSER_MAP.keys():
  if supported_lang in enry_data:
    for src_file in enry_data[supported_lang]:
      # Start timing parse
      parse_start_time = datetime.datetime.now()

      # Generate a UUID to use 
      uid = str(uuid.uuid5(
        uuid.NAMESPACE_URL,
        "https://{}/{}?at={}&branch={}".format(
          sys.argv[1],
          src_file,
          sys.argv[3],
          sys.argv[2]
        )
      ))

      # Args for popen
      pargs = [
        "bblfsh-cli", 
        "-a", 
        PARSER_MAP[supported_lang][0],
        "-l",
        PARSER_MAP[supported_lang][1],
        "--v2",
        './{}'.format(src_file)
      ]

      # Invoke bblfsh-cli (and handle possible failures)
      UAST = {}
      GOOD_PARSE = False
      info = {}
      try:
        # Do popen
        with Popen(pargs, stdout=PIPE, stderr=PIPE, universal_newlines=True) as proc:
          # Try and parser (timeout of 300 seconds)
          response, errs = proc.communicate(timeout=300)
          if errs is not None and len(errs) > 0:
            info['errors'] = errs
          info['response'] = response
          # Get the json
          as_json = json.loads(response)
          GOOD_PARSE = True
          # Reformat and encode
          UAST = json.dumps(as_json).encode('utf-8')
      except Exception as ex:
        # For exceptions just note the issues
        as_json = {}
        as_json['error'] = str(ex)
        as_json['details'] = info
        GOOD_PARSE = False
        UAST = json.dumps(as_json).encode('utf-8')
      del info

      # Save elapsed time (for parse)
      parse_elapsed_time = datetime.datetime.now() - parse_start_time

      # Stream this data out to stdout right away
      print('{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}'.format(
        uid,
        src_file,
        pathlib.Path(src_file).name,
        supported_lang,
        datetime.datetime.now().isoformat(),
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        '{:.3f}'.format(
          parse_elapsed_time.total_seconds() * 1000),
        'YES' if GOOD_PARSE else 'NO',
        base64.b64encode(UAST).decode('utf-8')
      ))
