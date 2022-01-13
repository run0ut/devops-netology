use food
// db.createCollection("fruits")
// db.fruits.insertMany([ {name: "apple", origin: "usa", price: 5}, {name: "orange", origin: "italy", price: 3}, {name: "mango", origin: "malaysia", price: 3} ])
db.fruits.find().pretty()

// // https://dba.stackexchange.com/questions/286913/how-to-simulate-slow-queries-on-mongodb
// db.fsyncLock()
// // https://rockset.com/blog/handling-slow-queries-in-mongodb-part-1-investigation/
// db.currentOp({ "active" : true, "secs_running" : { "$gt" : 100 }})
//db.killOp(10243)