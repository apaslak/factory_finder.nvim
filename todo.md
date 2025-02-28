shared_examples:
- include_examples
- it_behaves_like
- it_should_behave_like
- matching

shared_context:
- include_context

Loading the cache means rg should use "shared_examples" and "shared_context" with optional `RSpec.` prefix
Looking for an item in the cache needs to know about all the variations.

---

- "VeryLazy" makes it load "last" but it blocks other interaction with vim
