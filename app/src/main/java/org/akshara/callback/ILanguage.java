package org.akshara.callback;

import org.ekstep.genieservices.sdks.response.GenieListResponse;
import org.ekstep.genieservices.sdks.response.GenieResponse;

/**
 * Created by Jaya on 10/5/2015.
 */
public interface ILanguage {

    public void onSuccessLanguage(GenieListResponse genieListResponse);
    public void  onFailureLanguage(GenieListResponse genieListResponse);
}
