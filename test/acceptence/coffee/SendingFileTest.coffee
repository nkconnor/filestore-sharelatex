
assert = require("chai").assert
sinon = require('sinon')
chai = require('chai')
should = chai.should()
expect = chai.expect
modulePath = "../../../app/js/LocalFileWriter.js"
SandboxedModule = require('sandboxed-module')
fs = require("fs")
request = require("request")
settings = require("settings-sharelatex")

describe "Sending a file", ->

	before (done)->
		@localFileReadPath = "/tmp/filestore_acceptence_tests_file_read.txt"
		@localFileWritePath = "/tmp/filestore_acceptence_tests_file_write.txt"

		@constantFileContent = [
			"hello world"
			"line 2 goes here #{Math.random()}"
			"there are 3 lines in all"
		].join("\n")

		fs.writeFile(@localFileReadPath, @constantFileContent, done)
		@filestoreUrl = "http://localhost:#{settings.internal.filestore.port}"

	beforeEach (done)->
		fs.unlink @localFileWritePath, ->
			done()



	it "should send a 200 for status endpoing", (done)->
		request "#{@filestoreUrl}/status", (err, response, body)-> 
			response.statusCode.should.equal 200
			body.indexOf("filestore").should.not.equal -1
			body.indexOf("up").should.not.equal -1
			done()

	it "should be able get the file back", (done)->
		@timeout(1000 * 10)
		@fileUrl = "#{@filestoreUrl}/project/acceptence_tests/file/12345"

		writeStream = request.post(@fileUrl)

		writeStream.on "end", =>
			request.get @fileUrl, (err, response, body)=>
				body.should.equal @constantFileContent
				done()

		fs.createReadStream(@localFileReadPath).pipe writeStream


