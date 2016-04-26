#!/usr/bin/gawk -f
# parse input from : git log --stat 
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }
function getDomain(fname){
    if (split(fname, tmp, "/") < 2){
        return "top";
    }else{
        if ((tmp[1] == "src") || (tmp[1] == "interface")){
            return "src/" tmp[2] 
        }
        if (tmp[1] == "testing"){
            if (tmp[2] == "sct")
                return "sct";
            if (tmp[2] == "EI")
                return "EI";
            return "utmt/" tmp[2] 
        }
        return "general";
    }
}

#Extract category tag from description field per regular expression
function getCategory(desc){
    if (match(desc, /PR\s*[0-9ESP]+/)){
        return "PR|" gensub(/^.*PR\s*([0-9ESP]+).*$/, "\\1", "g", desc);
    }
    if (match(desc, /((LTE|LBT)\s*[-0-9A-Za-z]+)/)){
        return "NF|" gensub(/^.*((LTE|LBT)\s*[-0-9A-Za-z]+).*$/, "\\1", "g", desc);
    }
    if (desc ~ / [0-9]{4}(-[-a-zA-Z]+)?/){
        return "NF|" gensub(/^.* ([0-9]{4}(-[-a-zA-Z]+)?))\s+.*$/, "\\1", "g", desc);
    }
    if (match(desc, /(ECL)\s*adap/)){
        return "ECL|ECL";
    }
    if (match(desc, /OPEN_CPRI\]\s*([-a-zA-Z0-9]+)/)){
        return "OpenCpri|" gensub(/.*OPEN_CPRI\]\s*([-a-zA-Z0-9]+).*$/, "\\1", "g", desc);
    }
    if (match(desc, /IN META/)){
        return "META|META";
    }
    if ((desc ~ /for\s+APD/) || (desc ~ /\s+APD\s+/)){
        return "NF|LTE1656";
    }
    return "GEN|GEN";
}

#Special handling to mask certain special changes
function maskChangeSize(fname, lenStr, desc){
    if ((desc ~ /ut mt structure refine/) || (desc ~ /move unused files/))
        return 1;
    if ((lenStr == "Bin") || (fname ~ /^3rdparty\//) || (fname ~ /etc\/rom\//))
        return 1;
    if ((fname ~ /IM[dD]ump\.xml$/) || (fname ~ /\.xsd$/))
        return lenStr/100;
    if ((fname ~ /testing\/sct\/.*\.xml$/) || (fname ~ /^tools\//) || (fname ~ /\/json(cpp)?\./))
        return 10;
    if ((fname ~ /Doxyfile/) || (fname ~ /\/gcovr\.py/) || (fname ~ /\.rst$/))
        return 5;
    return lenStr;
}

#Fetch the prefix before sep 
function getPrefixBefore(fid, sep){
    idx = index(fid, sep);
    if (idx > 0)
        return substr(fid, 1, idx - length(sep));
    else
        return fid;
}

function getMonth(dateStr){
    split(dateStr, tmp, " ")
    return tmp[5] "-" months[tmp[2]] 
}

BEGIN{
    RS = "\ncommit ";
    FS = "\n";
    m=split("Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec",d,"|")
    for(o=1;o<=m;o++){
        months[d[o]]=sprintf("%02d",o)
    }
}
{
    commitId = $1;
    author = gensub(/Author:\s+([^\s]+)\s.*/, "\\1", "g", $2);
    date = gensub(/Date:\s+(.*)$/, "\\1", "g", $3);
    month = getMonth(date)
    desc = trim($5);
    split(getCategory(desc), tmp, "|")
    cat = tmp[1]
    catId = tmp[2]
    catParent = getPrefixBefore(catId, "-")
    for (idx = 10; idx <= NF; ++idx){
        if (split($idx, tmp, "|") == 2){
            fname = trim(tmp[1]);
            split(trim(tmp[2]), tmp, " ")
            change = tmp[1];
            printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n", commitId, fname, getDomain(fname), month,
                date, author, cat, catId, catParent, gensub(/,/, "", "g", desc),
                maskChangeSize(fname, change, desc));
        }
    }
}