user_schema = {
  "type" : "object",
  "properties" : {
    "name" : {"type" : "string"},
    "email" : {"type" : "string"},
    "password": {"type": "string"},
    # "age": {"type": "int"},
    # "gender": {"type": "string"},
    "records": {"type": "array"} # list of object ids of all records
  },
}

record_schema = {
  "type": "object",
  "properties": {
    "left_sequence_data": {"type": "array"},
    "right_sequence_data": {"type": "array"},
    # TODO: processed_data
  }
}