#!/usr/bin/python
# DIGI SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY,
# PROVIDED HEREUNDER IS PROVIDED "AS IS" AND WITHOUT WARRANTY OF ANY KIND.
# DIGI HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
# ENHANCEMENTS, OR MODIFICATIONS.
##IN NO EVENT SHALL DIGI BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
# SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS,
# ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
# DIGI HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
"""
NOTE: This code allows SMS messages to be sent and received and should be
reviewed before implementing. If you allow SMS incoming messages to modify or run
commands on the device, all incoming messages should be encrypted and validated
prior to execution.
"""
import os
import threading
import sys
from digidevice.sms import Callback, send
COND = threading.Condition()
def sms_test_callback(sms, condtion):
   print(f"SMS message from {sms['from']} received")
   print(sms)
   condition.acquire()
   condition.notify()
   condition.release()
def send_sms(destination, msg):
   print("sending SMS message", msg)
   if len(destination) > 10:
    # destination =  destination
    #  msg = 123
    #  msg2=str(msg)
    print(destination)
    print ("is too long")
   # send(destination, msg)
if __name__ == '__main__':
    if len(sys.argv) > 1:
        dest = sys.argv[1]
        print(dest)
    else:
        dest = '16464849595'
    my_callback = Callback(sms_test_callback, COND)
    send_sms("+" + dest, 'Hello World!')
    print("Please send an SMS message now.")
    print("Execution halted until a message is received or 60 seconds have passed.")
    # acquire the semaphore and wait until a callback occurs
    COND.acquire()
    try:
        COND.wait(60.0)
    except Exception as err:
        print("exception occured while waiting")
        print(err)
    COND.release()
    my_callback.unregister_callback()
#