function uriescape {
	escaped=`echo "$1" | tr '\012\015' '  ' | sed 's/ /%20/g; s/#/%23/g; s/\*/\\*/g; s/{/\\\{/g; s/}/\\\}/g; s/\?/%3f/g; s/&/%38/g; s/+/%2b/g; s/"/\\"/g; s/\[/\\\[/g; s/\]/\\\]/g; s/%20$//'`
}

function postescape {
	escaped=`echo "$1" | sed 's/ /%20/g; s/\*/\\*/g; s/\?/%3f/g; s/&/%38/g; s/+/%2b/g;'`
}

# usage: sparql $endpoint $query $extra_cgi
function sparql {
	uriescape "$2";
	echo "Query: $2"
	curl -s -H "Accept: text/plain" "$1/sparql/?query=${escaped}$3"
}

# usage: sparql $endpoint $query $api_key
function sparqlkey {
	uriescape "$2";
	echo "Query: $2"
	curl -s -H "Accept: text/plain" "$1/sparql/?query=$escaped&apikey=$3"
}

# usage: update $endpoint $update
function update {
        postescape "$2"
        echo "Update: $2"
        curl -s -d "update=$escaped" "$1/update/"
}

# usage: put $endpoint $file $mime-type $model
function put {
	uriescape $4;
	curl -s -T "$2" -H "Content-Type: $3" "$1/data/?graph=$escaped" | sed 's/ v[.0-9a-z-]*/ [VERSION]/'
}

# usage: put-old $endpoint $file $mime-type $model
function put-old {
	uriescape $4;
	curl -s -T "$2" -H "Content-Type: $3" "$1/data/$escaped" | sed 's/ v[.0-9a-z-]*/ [VERSION]/'
}

# usage: post $endpoint $data $mime-type $model
function post {
	uriescape "$3";
	emime=$escaped
	uriescape "$4";
	egraph=$escaped;
	uriescape "$2"
	curl -s -H 'Accept: text/plain' -d "mime-type=$emime" -d "graph=$egraph" -d "data=$escaped" "$1/data/" | sed 's/ v[.0-9a-z-]*/ [VERSION]/'
}

# usage: delete $endpoint $model
function delete {
	uriescape $2;
	curl -s -X 'DELETE' $1/data/?graph=$escaped | sed 's/ v[.0-9a-z-]*/ [VERSION]/'
}

# usage: delete-old $endpoint $model
function delete-old {
	uriescape $2;
	curl -s -X 'DELETE' $1/data/$escaped | sed 's/ v[.0-9a-z-]*/ [VERSION]/'
}
