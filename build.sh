find ./bin/ -name '*.ml*' | xargs ocp-indent -i && find ./lib/ -name '*.ml*' | xargs ocp-indent -i \
&& dune build --profile release \
&& cp -v -f _build/default/bin/clt/main.bc.js www/js/ \
&& gzip -vkf9 www/js/main.bc.js

# && dune build --profile release \
