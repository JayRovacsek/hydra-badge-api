/* tslint:disable */
/* eslint-disable */
/**
 * Hydra API
 * Specification of the Hydra REST API
 *
 * OpenAPI spec version: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by the swagger code generator program.
 * https://github.com/swagger-api/swagger-codegen.git
 * Do not edit the class manually.
 */

import { DeclarativeInput } from './declarative-input';
 /**
 * 
 *
 * @export
 * @interface ProjectIdBody
 */
export interface ProjectIdBody {

    /**
     * name of the project
     *
     * @type {string}
     * @memberof ProjectIdBody
     */
    name?: string;

    /**
     * display name of the project
     *
     * @type {string}
     * @memberof ProjectIdBody
     */
    displayname?: string;

    /**
     * description of the project
     *
     * @type {string}
     * @memberof ProjectIdBody
     */
    description?: string;

    /**
     * homepage of the project
     *
     * @type {string}
     * @memberof ProjectIdBody
     */
    homepage?: string;

    /**
     * owner of the project
     *
     * @type {string}
     * @memberof ProjectIdBody
     */
    owner?: string;

    /**
     * when set to true the project gets scheduled for evaluation
     *
     * @type {boolean}
     * @memberof ProjectIdBody
     */
    enabled?: boolean;

    /**
     * when true the project's jobsets support executing dynamically defined RunCommand hooks. Requires the server and project's configuration to also enable dynamic RunCommand.
     *
     * @type {boolean}
     * @memberof ProjectIdBody
     */
    enableDynamicRunCommand?: boolean;

    /**
     * when set to true the project is displayed in the web interface
     *
     * @type {boolean}
     * @memberof ProjectIdBody
     */
    visible?: boolean;

    /**
     * @type {any}
     * @memberof ProjectIdBody
     */
    declarative?: any;
}
