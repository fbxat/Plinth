#
# This file is part of Plinth.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

"""
URLs for the XMPP module
"""

from django.conf.urls import patterns, url


urlpatterns = patterns(  # pylint: disable-msg=C0103
    'modules.xmpp.xmpp',
    url(r'^apps/xmpp/$', 'index', name='index'),
    url(r'^apps/xmpp/configure/$', 'configure', name='configure'),
    url(r'^apps/xmpp/register/$', 'register', name='register')
    )
