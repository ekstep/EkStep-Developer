package org.partner.activity;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.afollestad.materialdialogs.GravityEnum;
import com.afollestad.materialdialogs.MaterialDialog;
import com.google.gson.Gson;

import org.ekstep.genieservices.sdks.response.GenieResponse;
import org.partner.R;
import org.partner.Util.TelemetryEventGenertor;
import org.partner.Util.Util;
import org.partner.callback.ILanguage;
import org.partner.callback.ITelemetryData;
import org.partner.callback.LanguageResponseHandler;
import org.partner.callback.TelemetryResponseHandler;
import org.partner.fragment.DisplayChildProfileFragment;
import org.ekstep.genieservices.sdks.LanguageList;
import org.ekstep.genieservices.sdks.Partner;
import org.ekstep.genieservices.sdks.Telemetry;
import org.ekstep.genieservices.sdks.UserProfile;
import org.ekstep.genieservices.sdks.response.GenieListResponse;

public class MainActivity extends AppCompatActivity implements NavigationDrawer.FragmentDrawerListener,
        ITelemetryData {
    private boolean D= Util.DEBUG;
    private String TAG=MainActivity.class.getSimpleName();
    private Fragment fragment;
    private Context mContext;
    private Toolbar mToolbar;
    private TextView mToolbar_text;
    private NavigationDrawer mDrawerFragment;
    private ImageView mToolbar_menu;
    private Fragment mFragment;
    private FragmentManager mFragment_mgr;
    private DrawerLayout mDrawerLayout;
    private MaterialDialog materialDialog;
    private int writeDB=0;
    private Partner partner;
    private Telemetry telemetry;
    private UserProfile userProfile;
    private LanguageList languageList;
    private LanguageResponseHandler languageResponseHandler;
    private TelemetryResponseHandler telemetryResponseHandler;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if(D)
            Log.d(TAG,"onCreate");
        setContentView(R.layout.activity_home);

        mFragment_mgr = getSupportFragmentManager();
        if (savedInstanceState != null) {
            mFragment = getSupportFragmentManager().findFragmentByTag("mContent");
        }

        initWidget();




    }

    @Override
    protected void onRestart() {
        if(D)
            Log.d(TAG,"onRestart");
        super.onRestart();

    }

    private  void  initWidget() {
        mToolbar = (Toolbar) findViewById(R.id.toolbar); // Attaching the layout to the toolbar object
        mToolbar_text = (TextView) mToolbar.findViewById(R.id.toolbar_title);
        mToolbar_menu=(ImageView)mToolbar.findViewById(R.id.imageView_menu);
        mDrawerLayout=(DrawerLayout) findViewById(R.id.drawer_layout);
        mContext = MainActivity.this;
        mDrawerFragment = (NavigationDrawer)getSupportFragmentManager().findFragmentById(R.id.fragment_navigation_drawer);
        mDrawerFragment.setUp(R.id.fragment_navigation_drawer, mDrawerLayout, mToolbar);
        mDrawerFragment.setDrawerListener(this);
       /* ConfigModel configModel=new Util(mContext).getConfigModel();
        String ColorPrimary=configModel.getColorPrimary();
        String ColorPrimaryDark=configModel.getColorPrimaryDark();
        getWindow().setStatusBarColor(Color.parseColor(ColorPrimaryDark));
        mToolbar.setBackgroundColor(Color.parseColor(ColorPrimary));
*/

        displayView(0);

        //initialitize the partner
        partner=new Partner(MainActivity.this);
        userProfile=new UserProfile(MainActivity.this);
        telemetry=new Telemetry(MainActivity.this);
        //Store object
        Util util=(Util)mContext.getApplicationContext();
        util.setPartner(partner);
        util.setUserProfile(userProfile);
        util.setTelemetry(telemetry);
        util.setStartTime(System.currentTimeMillis());
        telemetryResponseHandler=new TelemetryResponseHandler(MainActivity.this);
        telemetry.send(TelemetryEventGenertor.generateOEStartEvent(mContext).toString(), telemetryResponseHandler);





    }




    @Override
    public void onDrawerItemSelected(View view, int position) {
        showMaterialDialog("Are you sure to exit?","","YES","CANCEL");
        materialDialog.show();
    }

    private void displayView(int position) {
        // Fragment fragment;

        switch (position) {
            case 0:
                 fragment = new DisplayChildProfileFragment();
                switchContent(fragment, 1, true);
                break;


            default:
                break;
        }

    }

    public void switchContent(Fragment fragment, int id, boolean addToBackStack) {
        this.mFragment = fragment;
        if (addToBackStack) {
            mFragment_mgr.beginTransaction().replace(R.id.container_body, fragment, "mContent").addToBackStack(null).commit();

        } else {
            mFragment_mgr.beginTransaction().replace(R.id.container_body, fragment).commit();
        }

    }


    @Override
    public void onBackPressed() {
        if (getSupportFragmentManager().getBackStackEntryCount()>1) {
            mToolbar_menu.setVisibility(View.VISIBLE);
            getSupportFragmentManager().popBackStack();
        }
    }

    private void showMaterialDialog(String title,String content, final String positiveText, String negativeText) {
        materialDialog=new MaterialDialog
                .Builder(MainActivity.this)
                .title(title)
                .content(content)
                .negativeText(negativeText)
                .positiveText(positiveText)
                .buttonsGravity(GravityEnum.CENTER)
                .autoDismiss(false)
                .callback(new MaterialDialog.ButtonCallback() {
                    @Override
                    public void onPositive(MaterialDialog dialog) {
                        dialog.dismiss();
                        //exit appln
                        exitApp();
                    }

                    @Override
                    public void onNegative(MaterialDialog dialog) {
                        super.onNegative(dialog);
                        dialog.dismiss();
                    }
                }).build();
        materialDialog.setCancelable(false);
    }

    public void showBackIcon(String title,Fragment fragment){
        mToolbar_menu.setVisibility(View.GONE);
        mToolbar_text.setText(title);
        mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
        this.mFragment=fragment;
    }
    public void showTitle(String title,Fragment fragment){
        mToolbar_menu.setVisibility(View.VISIBLE);
        mToolbar_text.setText(title);

    }



    public  boolean openApp(Context context, String packageName) {
        PackageManager manager = context.getPackageManager();
        try {
            //Toast.makeText(MainActivity.this, packageName, Toast.LENGTH_LONG).show();
            Intent intent = manager.getLaunchIntentForPackage(packageName);
            if (intent == null) {
                return false;
                //throw new PackageManager.NameNotFoundException();
            }
            intent.addCategory(Intent.CATEGORY_LAUNCHER);

            context.startActivity(intent);
            finish();
            return true;
        } catch (Exception e) {

            return false;

        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        if(D)
            Log.d(TAG, "onStop");
    }


    public  void exitApp(){
        if(D)
            Log.d(TAG,"exitApp");

        MainActivity.this.finish();
        openApp(MainActivity.this, Util.GENIE_PACKAGENAME);

    }

  @Override
    protected void onDestroy() {
        super.onDestroy();
        if (D)
            Log.d(TAG,"onDestroy: userProfile->"+userProfile+" partner-->"+partner);
        if(userProfile!=null)
            userProfile.finish();
        if (partner!=null)
            partner.finish();

        if (telemetry!=null)
            telemetry=null;
    }

    @Override
    public void onSuccessTelemetry(GenieResponse genieResponse) {
        if(D)
            Log.d(TAG," onSuccessTelemetry :"+genieResponse);

    }

    @Override
    public void onFailureTelemetry(GenieResponse genieResponse) {
        if(D)
            Log.d(TAG," onFailureTelemetry :"+genieResponse);

    }
}
