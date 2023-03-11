user_schema = {
  "type" : "object",
  "properties" : {
    "name" : {"type" : "string"},
    "email" : {"type" : "string"},
    "password": {"type": "string"},
    # "age": {"type": "int"},
    # "gender": {"type": "string"},
    "records": {"type": "array"}, # list of object ids of all records
    "devices": {"type": "array"}
  },
}

record_schema = {
  "type": "object",
  "properties": {
    "timestamp": {"type": "int"},
    "devices": {"type": "array"},
    "left_sequence_data": {"type": "array"},
    "right_sequence_data": {"type": "array"},
    # "devices": {"type": "array"}
    # TODO: processed_data
  }
}
