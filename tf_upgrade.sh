#! /bin/bash

#source ./dependency_reporter/scripts/functions.sh

function clone() {
    {
        git clone "$REPO_LOCATION"
    } || {
        echo "Repo not available at $REPO_LOCATION"
        exit 1
    }
}

function upgrade(){
    curr_tf_version="$1"
    curr_tf_patch="$2"
    tf_version="$3"
    tf_patch="$4"

    repo_name=$(ls)
    cd $repo_name

    last_commit=$(git log -n 1 master | grep commit | awk '{print $2}')
    tf_dirs=$(find . -name '*.tf' | xargs -n1 dirname | sort | uniq)

    tfenv use "0.${tf_version}.${tf_patch}"

    git checkout -b "upgrade${tf_version}" || {
        echo "updgrade${tf_version} branch already exists for $repo_name... Exiting"
        exit 1
    }

    # look in concourse dir for version and replace
    if [[ -d "./ci" ]]; then
        grep -rl 'terraform_version' ./ci | xargs sed -i "s/terraform_version/terraform_${tf_version}_version/g"
        grep -rl "0.${curr_tf_version}.[0-9]*" ./ci | grep "\.y[a]*ml" | xargs sed -i "s/0\.${curr_tf_version}\.[0-9]*/\(\(dataworks.terraform_${tf_version}_version\)\)/g"
        grep -rl "0.${curr_tf_version}.[0-9]*" ./ci | grep "\.tf" | xargs sed -i "s/0\.${curr_tf_version}\.[0-9]*/0.${tf_version}.${tf_patch}/g"
    fi

    # look in github actions dir for version and replace
    if [[ -d "./.github/workflows" ]]; then
        grep -rl 'terraform' ./.github/workflows tee >(xargs sed -i "s/0\.${curr_tf_version}\.[0-9]*/\${{ secrets.TERRAFORM_${tf_version}_VERSION }}/g") >(xargs sed -i "s/secrets.TERRAFORM_VERSION/secrets.TERRAFORM_${tf_version}_VERSION/g")
    fi

    # look in tf for mentions of versions, run tf update command and replace tf 11 syntax
    upgrade_command="terraform 0.${tf_version}upgrade -yes"
    terraform fmt -recursive
    for dir in $tf_dirs; do
        $upgrade_command $dir
        start_dir=$(pwd)
        cd $dir
        grep -rl 'required_version' . | tee >(xargs sed -i "s/0\.${curr_tf_version}\.[0-9]*/0.${tf_version}.${tf_patch}/g") >(xargs sed -i  "s/terraform_${curr_tf_version}/terraform_${tf_version}_version/g")
        grep -rl 'provider' . | xargs perl -0777 -pi -e "s/provider[\s]*\"aws\"[\s]*{[\s]*\n[\s]*version[\s]*=[\s]*\".*[0-9]*\.[0-9]*\.[0-9]*\"/provider \"aws\" {\nversion = \"~> 3.42.0\"/g"
        tf_files=$(find . -type f -name '*.tf')
        for file in $tf_files; do
          # find all files with HereDocs being used to avoid invalid substitutions
            eof_locations=$(cat $file | grep '<<[A-Z]*')
            # if files don't have HereDocs, replace all tf 11 syntax
            if [[ $? -eq 1 ]]; then
                perl -pi -e 's!\"\$\{([^\}]+?)\}\"!\1!' $file # tf11 = "${<anything>}" -> tf12+ = <anything>
            else
              # if there are HereDocs used in the file, read it line by line and replace tf 11 syntax in swap file
                touch swap.txt
                # flag for HereDoc blocks
                eof_block=false
                IFS=''; while read -r line; do
                    check_here_doc=$(echo "$line" | perl -ne 'print if s!<<([A-Z]+)!\1!' | awk '{print $NF}')
                    if [[ "$check_here_doc" != "" ]]; then
                        here_doc="$check_here_doc"
                    fi
                    echo "$line" | grep here_doc
                    if [[ $? -eq 0 ]] || [[ here_doc != "" ]]; then
                        echo "$line" >> swap.txt
                        if [[ eof_block ]]; then
                            eof_block=false
                        else
                            eof_block=true
                        fi
                    elif [[ eof_block ]]; then
                        echo "$line" >> swap.txt
                    else
                        echo $(echo "$line" | perl -pi -e 's!\"\$\{([^\}]+?)\}\"!\1!') >> swap.txt
                    fi
                done <$file
                mv swap.txt $file
            fi
        done
        cd $start_dir
    done

    terraform fmt -recursive

    git add .
    git commit -m "upgrade to tf${tf_version}.${tf_patch}"
    export get_branch="upgrade${tf_version}"
    git push -u origin "upgrade${tf_version}"
#    git request-pull $last_commit $REPO_LOCATION master
}

#check_argument $1 "Repo URL not provided... Exiting"

REPO_LOCATION=$1
export REPO_LOCATION

mkdir ./current_repo
cd ./current_repo

clone

grep -r "0.11.[0-9]*" .

if [[ $? -eq 0 ]]; then
    upgrade 11 0 12 31
    cd ../
fi

upgrade 12 31 13 7 $get_branch

cd ../../
rm -rf current_repo
