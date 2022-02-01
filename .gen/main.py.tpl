#!/usr/bin/env python
# coding=utf-8

import grpc

from datetime import datetime

from ndk import sdk_service_pb2, sdk_service_pb2_grpc, config_service_pb2

import logging
from logging.handlers import RotatingFileHandler

agent_name = "{{ getenv "APPNAME" }}"

if __name__ == "__main__":

    log_filename = f"/var/log/srlinux/stdout/{agent_name}.log"
    logging.basicConfig(
        handlers=[RotatingFileHandler(log_filename, maxBytes=3000000, backupCount=5)],
        format="%(asctime)s,%(msecs)03d %(name)s %(levelname)s %(message)s",
        datefmt="%H:%M:%S",
        level=logging.INFO,
    )
    logging.info("START TIME :: {}".format(datetime.now()))

    channel = grpc.insecure_channel("127.0.0.1:50053")
    metadata = [("agent_name", agent_name)]
    sdk_mgr_client = sdk_service_pb2_grpc.SdkMgrServiceStub(channel)

    response = sdk_mgr_client.AgentRegister(
        request=sdk_service_pb2.AgentRegistrationRequest(), metadata=metadata
    )
    logging.info(f"Agent succesfully registered! App ID: {response.app_id}")

    # Subscribe to configuration events
    request=sdk_service_pb2.NotificationRegisterRequest(op=sdk_service_pb2.NotificationRegisterRequest.Create)
    create_subscription_response = sdk_mgr_client.NotificationRegister(request=request, metadata=metadata)
    stream_id = create_subscription_response.stream_id
    logging.info(f"Create subscription response received. stream_id : {stream_id}")

    cfgsubreq = config_service_pb2.ConfigSubscriptionRequest()
    request = sdk_service_pb2.NotificationRegisterRequest(
     op=sdk_service_pb2.NotificationRegisterRequest.AddSubscription,
     stream_id=stream_id, config=cfgsubreq)
    subscription_response = sdk_mgr_client.NotificationRegister(request=request, metadata=metadata)

    stream_request = sdk_service_pb2.NotificationStreamRequest(stream_id=stream_id)
    sub_stub = sdk_service_pb2_grpc.SdkNotificationServiceStub(channel)
    stream_response = sub_stub.NotificationStream(stream_request, metadata=metadata)

    try:
      # Blocking call to wait for events
      for r in stream_response:
        logging.info(f"NOTIFICATION:: \n{r.notification}")
        for obj in r.notification:
            if obj.HasField('config') and obj.config.key.js_path == ".commit.end":
                logging.info('TO DO - commit.end config')
            else:
                logging.info('TO DO - Handle_ConfigNotification')
    except Exception as ex:
      logging.error( ex )
