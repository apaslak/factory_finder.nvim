#### where i am
trying to fix how it takes a long time to load when you start up neovim and it blocks other operations.
I'm trying to move the load_cache methods into an async loop but its throwing an error

---

- "VeryLazy" makes it load "last" but it blocks other interaction with vim

--
"include_context"

The realization I had was that the plugin could supply a "smart" function which essentionally
does `find_definition` for each type of cache it has and open the right one.

This would have the recommendation of suppressing notifications.

##
If I wanted to make this generic, the parts that are specific are:
- the rg command to search for files
- the caches should probably be different
- possibly parsing the line to insert matches into the cache
- parsing what's under the cursor to identify what to search for
-

# definition
packs/product_services/accountants_gusto_pro/bookkeeping_core/spec/support/bookkeeping_matchers.rb
- RSpec.shared_examples 'a categorized account mapping' do |category|
packs/product_services/zenpayroll_subgraph_spaghetti/subgraph_zenpayroll/spec/support/draft_payrolls/mutations/skip_payroll_mutation_setup.rb
- RSpec.shared_examples 'a successful skip payroll mutation' do


# usage
packs/product_services/accountants_gusto_pro/bookkeeping_core/spec/models/account_mapping/company_matching_program_spec.rb
- it_behaves_like 'a categorized account mapping', AccountMapping::Category::Other

packs/product_services/zenpayroll_subgraph_spaghetti/subgraph_zenpayroll/spec/graphql/draft_payrolls/mutations/skip_regular_payroll_spec.rb
- it_behaves_like 'a successful skip payroll mutation'


## TODO
- make it so you can selectively disable certain caches if you dont use them?
