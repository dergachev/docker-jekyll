new_post:
	test -n "$(title)" || read -p "Enter a title for your post: " title; \
		export title_slug=`echo $${title:-Untitled} | sed -E -e 's/[^[:alnum:]]/-/g' -e 's/^-+|-+$$//g' | tr -s '-' | tr A-Z a-z`; \
		export post_path=source/_posts/`date +%Y-%m-%d`-$$title_slug.markdown; \
		test -f $$post_path && { echo "Error: $$post_path already exists" ; exit 1; }; \
		echo "Creating $$post_path"; \
		echo "---"                                      >> $$post_path; \
		echo "layout: post"                             >> $$post_path; \
		echo "title: \"$$title\""                       >> $$post_path; \
		echo "date: `date +"%Y-%m-%d %H:%M:%S %z"`"     >> $$post_path; \
		echo "comments: true"                           >> $$post_path; \
		echo "categories: "                             >> $$post_path; \
		echo "---"                                      >> $$post_path; \
		vim $$post_path

#=================================================================================
# Deployment
#=================================================================================

deploy_repo_url = git@github.com:dergachev/dergachev.github.io.git
deploy_repo_branch = master
setup_deploy:
	rm -Rf deploy;
	@read -p "Enter github deploy URL [$(deploy_repo_url)]: " url; \
		read -p "Enter branch to use [$(deploy_repo_branch)]: " deploy_repo_branch; \
		git clone "$${url:-$(deploy_repo_url)}" -b "$${deploy_repo_branch:-$(deploy_repo_branch)}" deploy

#=================================================================================
# Utils
#=================================================================================

shell:
	$(MAKE) -s docker-run cmd=/bin/bash

docker-build:
	docker build -t dergachev/docker-jekyll docker/

prepare:
	mkdir -p source deploy
	chmod g+s source deploy 

new:
	$(MAKE) docker-run cmd="jekyll new source"
	$(MAKE) docker-run cmd="chmod -R g+w source"

serve:
	$(MAKE) -s docker-run cmd="jekyll serve -s source -d deploy"

build:
	$(MAKE) docker-run cmd="jekyll build -s source -d deploy"

deploy:
	cd deploy; git pull; git checkout -f .;
	$(MAKE) build
	cd deploy; git add .; git commit -m "Autocommit by docker-jekyll on `date`"; git push

docker-run: prepare
	docker run -t -i \
	-v `pwd`/source:/srv/docker-jekyll/source/ \
	-v `pwd`/deploy:/srv/docker-jekyll/deploy \
	-v `dirname $(SSH_AUTH_SOCK)`:`dirname $(SSH_AUTH_SOCK)` -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) \
	-p 4000:4000 \
	dergachev/docker-jekyll \
	/bin/bash -c "umask 002; $(cmd) $(args)"

.PHONY: deploy
