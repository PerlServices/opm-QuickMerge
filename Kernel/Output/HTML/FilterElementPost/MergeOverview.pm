# --
# Kernel/Output/HTML/FilterElementPostMergeOverview.pm
# Copyright (C) 2013-2015 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::MergeOverview;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;

    my @Templates = keys %{ $Param{Templates} || {} };
    @Templates    = map{ "AgentTicketOverview$_" }(qw/Small Medium Preview/) if !@Templates;

    return 1 if !grep{ $Templatename eq $_ }@Templates;

    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');
    my $Title          = $LanguageObject->Translate('Merge with oldest');
    my $Link           = $LanguageObject->Translate('Quick Merge');

    my $Snippet = qq*
        <li class="AlwaysPresent Bulk" id="QuickMerge">
            <script type="text/javascript">//<![CDATA[
                function quick_merge() {
                    var challenge_token = \$('input[name="ChallengeToken"]').val();
                    var merge_url = 
                        Core.Config.Get('Baselink') +
                        "ChallengeToken=" + challenge_token + 
                        ";Action=AgentTicketBulk;Subaction=Do;MergeToSelection=OptionMergeToOldest";

                    var has_selected = 0;
                    \$('input[name="TicketID"]:checked').each(function(){
                        merge_url += ";TicketID=" + \$(this).val();
                        has_selected++;
                    });

                    if ( has_selected < 2 ) {
                        return false;
                    }

                    \$.ajax({
                        type: 'GET',
                        url: merge_url,
                        success: function(data) {
                            window.location.reload(true);
                        } 
                    });
                }
            //]]>
            </script>
            <a href="#" onclick="quick_merge();" title="$Title">$Link</a>
        </li>
    *;

    #scan html output and generate new html input
    ${ $Param{Data} } =~ s{
        (
            </ul> \s*
            <!--HookEndDocumentActionRow-->
        )
    }{$Snippet $1}xmgs;

    return 1;
}

1;
