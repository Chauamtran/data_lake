rs.initiate( {
  _id : "datalake",
  members: [
    { _id: 0, host: "mongodb_node1:27017" },
    { _id: 1, host: "mongodb_node2:27017" },
    { _id: 2, host: "mongodb_node3:27017" }
  ]
});