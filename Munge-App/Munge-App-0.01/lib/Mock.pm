
=HEAD

BIG HACK prereq scanner on openshift attempts to download these because they're
moosex::declare classes. this costs time, bandwidth and cpu and should be avoided.

This is a workaround, since prereq finds these package statements.

=cut

## no critic
package Munge::Model::Account;

# fooling prereq scanner

package Munge::Model::Feed;

# fooling prereq scanner

package Munge::Model::Feed::Client;

# fooling prereq scanner

package Munge::Model::FeedItem;

# fooling prereq scanner

package Munge::Model::View::Feed;

# fooling prereq scanner

package Munge::Model::View::FeedItem;

# fooling prereq scanner

package Munge::Storage;

# fooling prereq scanner

package Munge::UUID;

# fooling prereq scanner

package Munge::Model::Feed::Parser;

# fooling prereq scanner

package Munge::Model::Feed::ParserItem;

# fooling prereq scanner

package Munge::Model::OPML;

# fooling prereq scanner

1;
