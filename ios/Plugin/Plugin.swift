//
//  Plugin.swift
//  CapacitorAppmetricaPlugin
//
//  Created by Nalivayko Ivan on 22.07.2022.
//


import Foundation
import Capacitor
import YandexMobileMetrica

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AppMetrica)
public class AppMetrica: CAPPlugin {

    /**
     * Инициализация плагина
     */
    @objc func activate(_ call: CAPPluginCall) {
        do {
            let config = try Converter.toConfig(config: call.options as NSDictionary)
            YMMYandexMetrica.activate(with: config)
            
            call.success()
        } catch {
            call.error("Не удалось инициализировать метрику")
        }
    }
    
    /**
     * Отправляет событие в App метрику
     */
    @objc func reportEvent(_ call: CAPPluginCall) {
        let evName = call.getString("name") ?? "Undefined";
        let evParams = call.getObject("params");

        YMMYandexMetrica.reportEvent(evName, parameters: evParams);
        
        call.success();
    }

    /**
     * Отправляет ошибку в App метрику
     */
    @objc func reportError(_ call: CAPPluginCall) {
        let errorName = call.getString("name") ?? "Undefined";
        let errorMessage = call.getString("error");
        
        let underlyingError = YMMError.init(identifier: "Underlying YMMError")
        let error = YMMError(
            identifier: errorName,
            message: errorMessage,
            parameters: nil, // Android not supported
            backtrace: Thread.callStackReturnAddresses,
            underlyingError: underlyingError
        )
        
        YMMYandexMetrica.report(error: error, onFailure: nil)

        call.success();
    }
    
    
    /**
     * eCommerce: Открытие страницы
     */
    @objc func showScreenEvent(_ call: CAPPluginCall) {
        let screen = Converter.toECommerceScreen(screen: call.options)
        YMMYandexMetrica.report(eCommerce: .showScreenEvent(screen: screen), onFailure: nil)

        call.success();
    }
    
    /**
     * eCommerce: Просмотр карточки товара
     */
    @objc func showProductCardEvent(_ call: CAPPluginCall) {
        do {
            let screen = Converter.toECommerceScreen(screen: call.options["screen"] as? [AnyHashable: Any] ?? [:])
            let product = try Converter.toECommerceProduct(product: call.options["product"] as? [AnyHashable: Any] ?? [:])
            
            YMMYandexMetrica.report(eCommerce: .showProductCardEvent(product: product, screen: screen), onFailure: nil)
            
            call.success();
        }
        catch let e as Converter.ValidationError {
            call.error(e.errorDescription ?? "Undefined error")
        }
        catch {
            call.error("Undefined error")
        }
    }
    
    /**
     * eCommerce: Просмотр страницы товара
     */
    @objc func showProductDetailsEvent(_ call: CAPPluginCall) {
        do {
            let referrer = Converter.toECommerceReferrer(referrer: call.options["referrer"] as? [AnyHashable: Any] ?? [:])
            let product = try Converter.toECommerceProduct(product: call.options["product"] as? [AnyHashable: Any] ?? [:])
            
            YMMYandexMetrica.report(eCommerce: .showProductDetailsEvent(product: product, referrer: referrer), onFailure: nil)
            
            call.success();
        }
        catch let e as Converter.ValidationError {
            call.error(e.errorDescription ?? "Undefined error")
        }
        catch {
            call.error("Undefined error")
        }
    }

}
