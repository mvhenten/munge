
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "turns baubles into trinkets",
  "AUTHOR" => "Matthijs van Henten <matthijs\@ischen.nl>",
  "BUILD_REQUIRES" => {
    "DBICx::TestDatabase" => 0,
    "Dancer::Test" => 0,
    "File::Slurp" => 0,
    "Sub::Override" => 0,
    "Test::More" => 0,
    "Test::Sweet" => 0,
    "Time::HiRes" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Munge-App",
  "EXE_FILES" => [
    "bin/fix-poster-images.pl",
    "bin/app.pl",
    "bin/sync.pl"
  ],
  "LICENSE" => "perl",
  "NAME" => "Munge::App",
  "PREREQ_PM" => {
    "Carp::Assert" => 0,
    "Crypt::SaltedHash" => 0,
    "Cwd" => 0,
    "DBD::mysql" => 0,
    "DBICx::TestDatabase" => 0,
    "DBIx::Class::Core" => 0,
    "DBIx::Class::Schema" => 0,
    "DBIx::Class::TimeStamp" => 0,
    "DBIx::Connector" => 0,
    "Dancer" => 0,
    "Dancer::Session::Cookie" => 0,
    "Dancer::Test" => 0,
    "Data::Dumper" => 0,
    "Data::UUID" => 0,
    "Data::Validate::Email" => 0,
    "DateTime" => 0,
    "DateTime::Format::HTTP" => 0,
    "DateTime::Format::Human::Duration" => 0,
    "DateTime::Format::MySQL" => 0,
    "Email::Send" => 0,
    "Email::Send::Gmail" => 0,
    "Email::Simple::Creator" => 0,
    "Exporter::Lite" => 0,
    "ExtUtils::MakeMaker" => 0,
    "File::Basename" => 0,
    "File::Slurp" => 0,
    "FindBin" => 0,
    "HTML::Restrict" => 0,
    "HTML::TreeBuilder::XPath" => 0,
    "HTTP::Status" => 0,
    "JSON" => 0,
    "LWP::UserAgent" => 0,
    "List::MoreUtils" => 0,
    "MIME::Base64" => 0,
    "Math::Base36" => 0,
    "Method::Signatures" => 0,
    "Moose" => 0,
    "MooseX::Declare" => 0,
    "MooseX::Method::Signatures" => 0,
    "MooseX::StrictConstructor" => 0,
    "MooseX::Types" => 0,
    "MooseX::Types::Moose" => 0,
    "Plack::Middleware::Deflater" => 0,
    "Proc::Fork" => 0,
    "Sub::Override" => 0,
    "Template" => 0,
    "Test::More" => 0,
    "Test::Sweet" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "XML::Feed" => 0,
    "XML::XPath" => 0,
    "YAML::Any" => 0,
    "base" => 0,
    "bytes" => 0,
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.01",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



