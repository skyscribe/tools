var jsonFile = require('jsonfile');
var fs = require('fs');
const spawn = require('child_process').spawn;
const srcDir = '/home/xwv648/srcs/cprih/'
const binDir = srcDir + 'bin/LinuxX86/'
const outfile = srcDir + 'iwyu.txt'
var cmds = '';

if (process.argv.length != 3){
    console.log("invalid argv number!");
    process.exit(1);
}

var filterStr=process.argv[2];
var result=[];

function runIWYU(){
    const output = spawn('iwyu_tool.py', ['-p', binDir]);
    var outlines = []
    output.stdout.on('data', (data) => {
        outlines.push(data);
    })
    output.stderr.on('data', (data) => {
        outlines.push(data);
    })
    output.on('exit', (code) => {
        outlines.forEach((val, index, arr) => {
            fs.writeFileSync(outfile, val, {flag: 'a+'});
        })
        console.log("IWYU executed done [records=%d]!", outlines.length);
    });
}

function filterCmds(){
    cmds = jsonFile.readFileSync(binDir + 'compile_commands.json.raw');
    cmds.forEach((val, index, array) => {
        if (val.file.includes(filterStr)){
            result.push(val);
        }
        if (index == cmds.length - 1){
            //write to output
            console.log('Filter result=%d records dumped to compile_commands.json!', result.length)
            fs.writeFileSync(binDir + 'compile_commands.json', JSON.stringify(result));
            runIWYU();
        }
    });
}

filterCmds()
