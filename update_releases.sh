#/bin/bash
set -x

export TEMP_DIR=/tmp/temp_dir
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

function main(){
    cd $TEMP_DIR

    git clone git@github.com:nurlanf/odoo-kube.git
    git clone git@github.com:odoo/docker.git

    for i in 11.0 12.0 13.0; do
        NEW_RELEASE=`grep "ARG ODOO_RELEASE" $TEMP_DIR/docker/$i/Dockerfile|awk '{print $2}'`
        OLD_RELEASE=`grep "ARG ODOO_RELEASE" $TEMP_DIR/odoo-kube/$i/Dockerfile|awk '{print $2}'`
        NEW_SHA=`grep "ARG ODOO_SHA" $TEMP_DIR/docker/$i/Dockerfile|awk '{print $2}'`
        OLD_SHA=`grep "ARG ODOO_SHA" $TEMP_DIR/odoo-kube/$i/Dockerfile|awk '{print $2}'`
        if [[ ${NEW_RELEASE} != ${OLD_RELEASE} ]]; then
            echo "Updating ${OLD_RELEASE} with ${NEW_RELEASE} for Odoo version $i"
            sed -i "s/${OLD_RELEASE}/${NEW_RELEASE}/" $TEMP_DIR/odoo-kube/$i/Dockerfile
            sed -i "s/${OLD_SHA}/${NEW_SHA}/" $TEMP_DIR/odoo-kube/$i/Dockerfile
            cd $TEMP_DIR/odoo-kube
            git add .
            git commit -m "Update to ${NEW_RELEASE} for Odoo version $i"
        else
            echo "There is no Release update for Odoo version $i"
        fi
    done

    cd $TEMP_DIR/odoo-kube
    git push origin master

}

main


